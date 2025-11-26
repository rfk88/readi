//
//  ProfileService.swift
//  Readi
//
//  Created by Readi Team
//

import Foundation

struct ProfileRequest: Codable {
    let name: String? // User's name from onboarding
    let role: String
    let displayName: String?
    let timeZone: String?
    let reminderMinutes: Int?
    let resumeUrl: String?
    let jobRole: String?
    let targetCompanies: [String]?
    let companyName: String?
    let productDescription: String?
    let salesPainPoints: String?
    let salesTargets: String?
    let preferredMeetingTypes: [String]?
    let notificationPreference: String?
    let notes: String?
    
    // No CodingKeys - using default camelCase to match backend
}

struct ProfileResponse: Codable {
    let profile: UserProfile
}

class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private let apiClient = APIClient.shared
    
    func createProfile(_ request: ProfileRequest) async throws -> UserProfile {
        let response: ProfileResponse = try await apiClient.post("/profiles", body: request)
        return response.profile
    }
    
    func getProfile() async throws -> UserProfile {
        let response: ProfileResponse = try await apiClient.get("/profiles/me")
        return response.profile
    }
    
    func updateProfile(_ request: ProfileRequest) async throws -> UserProfile {
        let response: ProfileResponse = try await apiClient.put("/profiles", body: request)
        return response.profile
    }
}

