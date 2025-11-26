//
//  OnboardingViewModel.swift
//  Readi
//
//  Created by Readi Team
//

import Foundation
import SwiftUI
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    // Step 1: Role selection (after sign-in)
    @Published var selectedRole: ProfileRole?
    @Published var roleConfirmed = false
    
    // Step 2: Profile details
    @Published var name = ""
    @Published var displayName = ""
    @Published var timeZone = TimeZone.current.identifier
    @Published var reminderMinutes: ReminderTiming = .minutes30
    @Published var resumeUrl = ""
    @Published var jobRole = ""
    @Published var targetCompaniesInput = ""
    @Published var companyName = ""
    @Published var productDescription = ""
    @Published var salesPainPoints = ""
    @Published var salesTargets = ""
    @Published var preferredMeetingTypes: [String] = []
    @Published var notificationPreference: NotificationPreference = .push
    @Published var notes = ""
    
    @Published var isLoading = false
    @Published var error: String?
    @Published var isComplete = false
    
    private let profileService = ProfileService.shared
    
    var targetCompanies: [String] {
        targetCompaniesInput
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var canProceedFromRoleSelection: Bool {
        selectedRole != nil
    }
    
    // Can proceed from step 2 (profile details)
    var canProceedFromStep2: Bool {
        guard let role = selectedRole else { return false }
        
        let hasName = !name.trimmingCharacters(in: .whitespaces).isEmpty
        
        switch role {
        case .jobSeeker:
            return hasName && !jobRole.isEmpty && !targetCompanies.isEmpty
        case .sales:
            return hasName && !companyName.isEmpty && !productDescription.isEmpty
        }
    }
    
    // Submit profile (step 2 - after Google sign-in)
    func submitProfile() async {
        guard let role = selectedRole else { return }
        
        isLoading = true
        error = nil
        
        let request = ProfileRequest(
            name: name.trimmingCharacters(in: .whitespaces).isEmpty ? nil : name.trimmingCharacters(in: .whitespaces),
            role: role.rawValue,
            displayName: displayName.trimmingCharacters(in: .whitespaces).isEmpty ? nil : displayName.trimmingCharacters(in: .whitespaces),
            timeZone: timeZone,
            reminderMinutes: reminderMinutes.rawValue,
            resumeUrl: resumeUrl.isEmpty ? nil : resumeUrl,
            jobRole: jobRole.isEmpty ? nil : jobRole,
            targetCompanies: targetCompanies.isEmpty ? nil : targetCompanies,
            companyName: companyName.isEmpty ? nil : companyName,
            productDescription: productDescription.isEmpty ? nil : productDescription,
            salesPainPoints: salesPainPoints.isEmpty ? nil : salesPainPoints,
            salesTargets: salesTargets.isEmpty ? nil : salesTargets,
            preferredMeetingTypes: preferredMeetingTypes.isEmpty ? nil : preferredMeetingTypes,
            notificationPreference: notificationPreference.rawValue,
            notes: notes.isEmpty ? nil : notes
        )
        
        do {
            print("📤 Sending profile request: \(String(data: try JSONEncoder().encode(request), encoding: .utf8) ?? "failed to encode")")
            _ = try await profileService.createProfile(request)
            print("✅ Profile saved successfully")
            isComplete = true
        } catch let apiError as APIError {
            print("❌ Profile save API error: \(apiError)")
            switch apiError {
            case .httpError(let statusCode, let message):
                self.error = message ?? "Server error (\(statusCode)). Please try again."
            case .unauthorized:
                self.error = "Your session expired. Please sign in again."
            case .networkError(let error):
                self.error = "Connection error: \(error.localizedDescription)"
            default:
                self.error = apiError.localizedDescription
            }
        } catch {
            print("❌ Profile save error: \(error)")
            self.error = "Couldn't save your profile: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func toggleMeetingType(_ type: String) {
        if let index = preferredMeetingTypes.firstIndex(of: type) {
            preferredMeetingTypes.remove(at: index)
        } else {
            preferredMeetingTypes.append(type)
        }
    }
    
    func isMeetingTypeSelected(_ type: String) -> Bool {
        preferredMeetingTypes.contains(type)
    }
}

enum NotificationPreference: String, CaseIterable, Identifiable {
    case push
    case email
    case both
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .push: return "Push Notifications"
        case .email: return "Email"
        case .both: return "Push & Email"
        }
    }
}

enum ReminderTiming: Int, CaseIterable, Identifiable {
    case minutes15 = 15
    case minutes30 = 30
    case minutes60 = 60
    
    var id: Int { rawValue }
    
    var label: String {
        switch self {
        case .minutes15: return "15 min before"
        case .minutes30: return "30 min before"
        case .minutes60: return "60 min before"
        }
    }
}

