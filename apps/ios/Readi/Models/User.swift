//
//  User.swift
//  Readi
//
//  Created by Readi Team
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String?
    let createdAt: Date
    let profile: UserProfile?
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, profile
        case createdAt = "created_at"
    }
}

struct UserProfile: Codable {
    // Prisma always returns these fields
    let id: String
    let userId: String
    let role: ProfileRole
    let displayName: String?
    let timeZone: String?
    let reminderMinutes: Int
    let resumeUrl: String?
    let jobRole: String?
    let targetCompanies: [String]
    let companyName: String?
    let productDescription: String?
    let salesPainPoints: String?
    let salesTargets: String?
    let preferredMeetingTypes: [String]
    let notificationPreference: String
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
    
    // Nested user relation (optional, may not always be included)
    let user: ProfileUser?
    
    // No CodingKeys - using default camelCase to match backend Prisma JSON output
}

// Minimal user info returned with profile
struct ProfileUser: Codable {
    let id: String
    let email: String
    let name: String?
}

enum ProfileRole: String, Codable, CaseIterable {
    case jobSeeker = "job_seeker"
    case sales = "sales"
    
    var displayName: String {
        switch self {
        case .jobSeeker: return "Job Seeker"
        case .sales: return "Sales Professional"
        }
    }
    
    var description: String {
        switch self {
        case .jobSeeker:
            return "Preparing for interviews and career opportunities"
        case .sales:
            return "Meeting with clients and prospects"
        }
    }
}

