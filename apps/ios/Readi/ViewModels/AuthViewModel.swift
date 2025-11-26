//
//  AuthViewModel.swift
//  Readi
//
//  Created by Readi Team
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?
    
    private let authService = AuthService.shared
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        let hasToken = authService.isAuthenticated
        // Don't set isAuthenticated to true until we verify the token is valid
        if hasToken {
            // Token exists, but we need to verify it's valid
            // isAuthenticated will be set to true after successful fetchCurrentUser
            isAuthenticated = false // Start as false until verified
        } else {
            // No token, ensure we're logged out
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    func signInWithGoogle() async {
        isLoading = true
        error = nil
        
        do {
            // ASWebAuthenticationSession handles the OAuth flow and stores token automatically
            _ = try await authService.signInWithGoogle()
            // Token is now stored, fetch user to verify and set authenticated state
            await fetchCurrentUser()
        } catch {
            self.error = error.localizedDescription
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    // Legacy callback handler (kept for compatibility, but ASWebAuthenticationSession handles it now)
    func handleAuthCallback(token: String) async {
        authService.handleAuthCallback(token: token)
        // Fetch user to verify token and set authenticated state
        await fetchCurrentUser()
    }
    
    func fetchCurrentUser() async {
        do {
            currentUser = try await authService.getCurrentUser()
            // Only set authenticated to true after successful fetch
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
            if case APIError.unauthorized = error {
                // Invalid token, clear everything
                logout()
            } else {
                // Other error, but token might still be valid
                // Keep isAuthenticated false until we can verify
                isAuthenticated = false
            }
        }
    }
    
    func logout() {
        authService.logout()
        isAuthenticated = false
        currentUser = nil
        // Reset welcome state so user can sign in again
        UserDefaults.standard.set(false, forKey: "hasSeenWelcome")
    }
}

