//
//  ReadiApp.swift
//  Readi
//
//  Created by rami kaawach on 2025-11-20.
//

import SwiftUI

@main
struct ReadiApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var isCheckingAuth = true
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isCheckingAuth {
                    // Show loading while checking auth status
                    ProgressView("Loading...")
                        .task {
                            // Wait for auth check to complete
                            if authViewModel.isAuthenticated {
                                await authViewModel.fetchCurrentUser()
                            }
                            isCheckingAuth = false
                        }
                } else if !hasSeenWelcome {
                    // Step 0: Welcome screen
                    WelcomeView(hasSeenWelcome: $hasSeenWelcome)
                } else if authViewModel.isAuthenticated {
                    // User is signed in
                    if authViewModel.currentUser?.profile != nil {
                        // Has profile - show dashboard
                        ContentView()
                    } else {
                        // No profile - continue onboarding
                        OnboardingView()
                    }
                } else {
                    // Not signed in - show sign-in view
                    SignInView()
                }
            }
            .environmentObject(authViewModel)
            .onOpenURL { url in
                // Handle OAuth callback
                if url.scheme == "readi",
                   url.host == "auth",
                   url.path == "/callback",
                   let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let token = components.queryItems?.first(where: { $0.name == "token" })?.value {
                    Task {
                        await authViewModel.handleAuthCallback(token: token)
                    }
                }
            }
        }
    }
}
