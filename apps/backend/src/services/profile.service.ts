import { prisma } from '../lib/prisma.js';

export interface ProfileData {
  role: 'job_seeker' | 'sales';
  name?: string; // User's name from onboarding
  displayName?: string;
  timeZone?: string;
  reminderMinutes?: number;
  // Job Seeker fields
  resumeUrl?: string;
  jobRole?: string;
  targetCompanies?: string[];
  // Sales fields
  companyName?: string;
  productDescription?: string;
  salesPainPoints?: string;
  salesTargets?: string;
  // Shared preferences
  preferredMeetingTypes?: string[];
  notificationPreference?: 'push' | 'email' | 'both';
  notes?: string;
  // Additional flexible data
  profileData?: Record<string, any>;
}

export class ProfileService {
  /**
   * Create or update user profile
   */
  async upsertProfile(userId: string, data: ProfileData) {
    // Update user's name if provided
    if (data.name) {
      await prisma.user.update({
        where: { id: userId },
        data: { name: data.name },
      });
    }

    const profile = await prisma.profile.upsert({
      where: { userId },
      update: {
        role: data.role,
        displayName: data.displayName,
        timeZone: data.timeZone,
        reminderMinutes: data.reminderMinutes ?? 30,
        resumeUrl: data.resumeUrl,
        jobRole: data.jobRole,
        targetCompanies: data.targetCompanies,
        companyName: data.companyName,
        productDescription: data.productDescription,
        salesPainPoints: data.salesPainPoints,
        salesTargets: data.salesTargets,
        preferredMeetingTypes: data.preferredMeetingTypes,
        notificationPreference: data.notificationPreference ?? 'push',
        notes: data.notes,
        profileData: data.profileData,
      },
      create: {
        userId,
        role: data.role,
        displayName: data.displayName,
        timeZone: data.timeZone,
        reminderMinutes: data.reminderMinutes ?? 30,
        resumeUrl: data.resumeUrl,
        jobRole: data.jobRole,
        targetCompanies: data.targetCompanies ?? [],
        companyName: data.companyName,
        productDescription: data.productDescription,
        salesPainPoints: data.salesPainPoints,
        salesTargets: data.salesTargets,
        preferredMeetingTypes: data.preferredMeetingTypes ?? [],
        notificationPreference: data.notificationPreference ?? 'push',
        notes: data.notes,
        profileData: data.profileData,
      },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            name: true,
          },
        },
      },
    });

    return profile;
  }

  /**
   * Get user profile
   */
  async getProfile(userId: string) {
    const profile = await prisma.profile.findUnique({
      where: { userId },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            name: true,
            createdAt: true,
          },
        },
      },
    });

    return profile;
  }

  /**
   * Delete user profile
   */
  async deleteProfile(userId: string) {
    await prisma.profile.delete({
      where: { userId },
    });
  }
}

export const profileService = new ProfileService();

