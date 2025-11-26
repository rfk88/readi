//
//  OnboardingView.swift
//  Readi
//
//  Created by Readi Team
//

import SwiftUI

private let meetingTypeOptions = [
    "Interview Prep",
    "Discovery Calls",
    "Internal Reviews",
    "Executive Briefings",
    "Investor Updates"
]

private let commonTimeZones = [
    "America/Los_Angeles",
    "America/Chicago",
    "America/New_York",
    "Europe/London",
    "Asia/Dubai",
    "Asia/Singapore",
    "Australia/Sydney"
]

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            if !authViewModel.isAuthenticated {
                VStack(spacing: 16) {
                    Spacer()
                    Text("Please sign in to continue onboarding.")
                        .foregroundColor(.secondary)
                    Button("Back to sign in") {
                        authViewModel.logout()
                    }
                    Spacer()
                }
            } else if !viewModel.roleConfirmed {
                RoleSelectionStep(viewModel: viewModel)
            } else if let role = viewModel.selectedRole {
                ProfileSetupView(role: role, viewModel: viewModel)
            }
        }
        .onChange(of: viewModel.isComplete) { isComplete in
            if isComplete {
                Task { await authViewModel.fetchCurrentUser() }
            }
        }
    }
}

struct RoleSelectionStep: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("What type of prep do you need?")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 40)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 16) {
                    ForEach(ProfileRole.allCases, id: \.self) { role in
                        RoleCard(
                            role: role,
                            isSelected: viewModel.selectedRole == role
                        ) {
                            viewModel.selectedRole = role
                        }
                    }
                }
                .padding(.horizontal)
                
                Button {
                    viewModel.roleConfirmed = true
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(viewModel.canProceedFromRoleSelection ? Color.blue : Color.gray)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                }
                .disabled(!viewModel.canProceedFromRoleSelection)
                
                Spacer(minLength: 32)
            }
        }
    }
}

struct RoleCard: View {
    let role: ProfileRole
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.blue.opacity(0.15) : Color(.systemGray6))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: role == .jobSeeker ? "briefcase.fill" : "chart.line.uptrend.xyaxis")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(isSelected ? .blue : .secondary)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(role.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(role.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isSelected ? .blue.opacity(0.2) : .black.opacity(0.05),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }
}

struct ProfileSetupView: View {
    let role: ProfileRole
    @ObservedObject var viewModel: OnboardingViewModel
    
    private let gridColumns = [
        GridItem(.adaptive(minimum: 140), spacing: 12)
    ]
    
    var body: some View {
        VStack {
            Form {
                Section("Your details") {
                    TextField("Full name", text: $viewModel.name)
                        .textInputAutocapitalization(.words)
                    TextField("Preferred name (optional)", text: $viewModel.displayName)
                        .textInputAutocapitalization(.words)
                    Picker("Time zone", selection: $viewModel.timeZone) {
                        ForEach(commonTimeZones, id: \.self) { zone in
                            Text(TimeZone(identifier: zone)?.identifier ?? zone).tag(zone)
                        }
                    }
                    Picker("Reminder", selection: $viewModel.reminderMinutes) {
                        ForEach(ReminderTiming.allCases) { option in
                            Text(option.label).tag(option)
                        }
                    }
                }
                
                if role == .jobSeeker {
                    Section("Interview focus") {
                        TextField("Target role / title", text: $viewModel.jobRole)
                        TextField("Target companies (comma separated)", text: $viewModel.targetCompaniesInput)
                        TextField("Resume URL (optional)", text: $viewModel.resumeUrl)
                            .keyboardType(.URL)
                    }
                } else {
                    Section("Sales profile") {
                        TextField("Company name", text: $viewModel.companyName)
                        TextField("Product description", text: $viewModel.productDescription, axis: .vertical)
                            .lineLimit(3...6)
                        TextField("Customer pain points you solve", text: $viewModel.salesPainPoints, axis: .vertical)
                            .lineLimit(2...4)
                        TextField("Deals or customers you’re focused on", text: $viewModel.salesTargets, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }
                
                Section("Meeting focus areas") {
                    Text("Select the meeting types you want Readi to prioritize.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        ForEach(meetingTypeOptions, id: \.self) { option in
                            Button {
                                viewModel.toggleMeetingType(option)
                            } label: {
                                HStack {
                                    Image(systemName: viewModel.isMeetingTypeSelected(option) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(viewModel.isMeetingTypeSelected(option) ? .white : .blue)
                                    Text(option)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    viewModel.isMeetingTypeSelected(option)
                                    ? Color.blue
                                    : Color(.systemGray6)
                                )
                                .foregroundColor(viewModel.isMeetingTypeSelected(option) ? .white : .primary)
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Section("Notifications") {
                    Picker("Reminder channel", selection: $viewModel.notificationPreference) {
                        ForEach(NotificationPreference.allCases) { pref in
                            Text(pref.label).tag(pref)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Notes for Readi") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                }
            }
            
            VStack(spacing: 12) {
                if let error = viewModel.error {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button {
                    Task {
                        await viewModel.submitProfile()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Save & Continue")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(viewModel.canProceedFromStep2 ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(14)
                .disabled(!viewModel.canProceedFromStep2 || viewModel.isLoading)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .navigationTitle("Setup Your Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Change role") {
                    viewModel.roleConfirmed = false
                    viewModel.selectedRole = nil
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthViewModel())
}

