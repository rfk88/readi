//
//  AuthService.swift
//  Readi
//
//  Created by Readi Team
//

import Foundation
import AuthenticationServices
import UIKit

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct MeResponse: Codable {
    let user: User
}

class AuthService: NSObject {
    static let shared = AuthService()
    private override init() {
        super.init()
    }
    
    private let apiClient = APIClient.shared
    private var authSession: ASWebAuthenticationSession?
    
    @MainActor
    func signInWithGoogle() async throws -> String {
        // ASWebAuthenticationSession requires HTTPS, but for local dev we use HTTP
        // Solution: Open URL directly in Safari for local development
        #if targetEnvironment(simulator)
        let authURL = "http://localhost:4000/api/v1/auth/google"
        #else
        let authURL = "http://192.168.70.198:4000/api/v1/auth/google"
        #endif
        
        guard let url = URL(string: authURL) else {
            throw APIError.invalidURL
        }
        
        // For local HTTP, we need to handle it differently
        // ASWebAuthenticationSession doesn't support HTTP in newer iOS versions
        // We'll use it anyway but handle the deprecation warning
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: "readi"
            ) { callbackURL, error in
                if let error = error {
                    print("❌ ASWebAuthenticationSession error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let callbackURL = callbackURL else {
                    print("❌ No callback URL received")
                    continuation.resume(throwing: APIError.invalidResponse)
                    return
                }
                
                print("✅ Callback URL received: \(callbackURL.absoluteString)")
                
                guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false) else {
                    print("❌ Failed to parse callback URL")
                    continuation.resume(throwing: APIError.invalidResponse)
                    return
                }
                
                // Check for error in callback
                if let errorParam = components.queryItems?.first(where: { $0.name == "error" })?.value {
                    print("❌ Error in callback: \(errorParam)")
                    continuation.resume(throwing: APIError.httpError(statusCode: 400, message: errorParam))
                    return
                }
                
                // Get token from callback
                guard let token = components.queryItems?.first(where: { $0.name == "token" })?.value else {
                    print("❌ No token in callback URL. Query items: \(components.queryItems ?? [])")
                    continuation.resume(throwing: APIError.invalidResponse)
                    return
                }
                
                print("✅ Token received, storing...")
                // Store token and return success
                KeychainManager.shared.authToken = token
                continuation.resume(returning: "Authentication successful")
            }
            
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false // Allow cookie sharing
            
            self.authSession = session
            
            if !session.start() {
                continuation.resume(throwing: APIError.invalidURL)
            }
        }
    }
    
    func handleAuthCallback(token: String) {
        KeychainManager.shared.authToken = token
    }
    
    func getCurrentUser() async throws -> User {
        let response: MeResponse = try await apiClient.get("/auth/me")
        return response.user
    }
    
    func logout() {
        KeychainManager.shared.authToken = nil
    }
    
    var isAuthenticated: Bool {
        KeychainManager.shared.authToken != nil
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension AuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Get the key window (Apple best practice)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window available for authentication")
        }
        return window
    }
}

