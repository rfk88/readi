import { google } from 'googleapis';
import { prisma } from '../lib/prisma.js';
import { env } from '../config/env.js';

export interface GoogleTokens {
  access_token: string;
  refresh_token?: string;
  expiry_date: number;
  scope: string;
}

export interface GoogleUserInfo {
  id: string;
  email: string;
  name?: string;
  picture?: string;
}

export class AuthService {
  private oauth2Client;

  constructor() {
    this.oauth2Client = new google.auth.OAuth2(
      env.GOOGLE_CLIENT_ID,
      env.GOOGLE_CLIENT_SECRET,
      env.GOOGLE_REDIRECT_URI
    );
  }

  /**
   * Get Google OAuth URL for user authorization
   */
  getAuthorizationUrl(): string {
    const scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/calendar.readonly',
      'https://www.googleapis.com/auth/gmail.readonly',
    ];

    return this.oauth2Client.generateAuthUrl({
      access_type: 'offline',
      scope: scopes,
      prompt: 'consent', // Force consent to get refresh token
    });
  }

  /**
   * Exchange authorization code for tokens
   */
  async getTokensFromCode(code: string): Promise<GoogleTokens> {
    const { tokens } = await this.oauth2Client.getToken(code);
    
    if (!tokens.access_token) {
      throw new Error('No access token received from Google');
    }

    return {
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token ?? undefined,
      expiry_date: tokens.expiry_date || Date.now() + 3600 * 1000,
      scope: tokens.scope || '',
    };
  }

  /**
   * Get user info from Google
   */
  async getUserInfo(accessToken: string): Promise<GoogleUserInfo> {
    this.oauth2Client.setCredentials({ access_token: accessToken });
    
    const oauth2 = google.oauth2({ version: 'v2', auth: this.oauth2Client });
    const { data } = await oauth2.userinfo.get();

    if (!data.email || !data.id) {
      throw new Error('Invalid user info received from Google');
    }

    return {
      id: data.id,
      email: data.email,
      name: data.name || undefined,
      picture: data.picture || undefined,
    };
  }

  /**
   * Create or update user with Google credentials
   */
  async upsertUser(userInfo: GoogleUserInfo, tokens: GoogleTokens) {
    const user = await prisma.user.upsert({
      where: { googleId: userInfo.id },
      update: {
        email: userInfo.email,
        name: userInfo.name,
      },
      create: {
        email: userInfo.email,
        googleId: userInfo.id,
        name: userInfo.name,
      },
    });

    // Store/update tokens
    await prisma.userToken.upsert({
      where: {
        userId: user.id,
      },
      update: {
        accessToken: tokens.access_token,
        refreshToken: tokens.refresh_token ?? undefined,
        expiresAt: new Date(tokens.expiry_date),
        scope: tokens.scope,
      },
      create: {
        userId: user.id,
        accessToken: tokens.access_token,
        refreshToken: tokens.refresh_token ?? undefined,
        expiresAt: new Date(tokens.expiry_date),
        scope: tokens.scope,
      },
    });

    return user;
  }

  /**
   * Refresh Google access token
   */
  async refreshAccessToken(userId: string): Promise<string> {
    const userToken = await prisma.userToken.findFirst({
      where: { userId },
    });

    if (!userToken?.refreshToken) {
      throw new Error('No refresh token found');
    }

    this.oauth2Client.setCredentials({
      refresh_token: userToken.refreshToken,
    });

    const { credentials } = await this.oauth2Client.refreshAccessToken();

    if (!credentials.access_token) {
      throw new Error('Failed to refresh access token');
    }

    // Update stored token
    await prisma.userToken.update({
      where: { id: userToken.id },
      data: {
        accessToken: credentials.access_token,
        expiresAt: new Date(credentials.expiry_date || Date.now() + 3600 * 1000),
      },
    });

    return credentials.access_token;
  }

  /**
   * Get valid Google access token for user (refresh if needed)
   */
  async getValidAccessToken(userId: string): Promise<string> {
    const userToken = await prisma.userToken.findFirst({
      where: { userId },
    });

    if (!userToken) {
      throw new Error('No token found for user');
    }

    // Check if token is expired or about to expire (within 5 minutes)
    const expiryBuffer = 5 * 60 * 1000;
    if (userToken.expiresAt.getTime() < Date.now() + expiryBuffer) {
      return this.refreshAccessToken(userId);
    }

    return userToken.accessToken;
  }
}

export const authService = new AuthService();

