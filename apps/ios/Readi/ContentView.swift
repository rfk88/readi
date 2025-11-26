//
//  ContentView.swift
//  Readi
//
//  Created by rami kaawach on 2025-11-20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Meetings", systemImage: "calendar")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.meetings.isEmpty {
                    ProgressView("Loading meetings...")
                } else if viewModel.meetings.isEmpty {
                    EmptyMeetingsView(onSync: {
                        Task {
                            await viewModel.syncCalendar()
                        }
                    })
                } else {
                    MeetingListView(meetings: viewModel.meetings)
                }
            }
            .navigationTitle("Upcoming Meetings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.syncCalendar()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isSyncing)
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                if viewModel.meetings.isEmpty {
                    await viewModel.loadMeetings()
                }
            }
        }
    }
}

struct MeetingListView: View {
    let meetings: [Meeting]
    
    var body: some View {
        List(meetings) { meeting in
            NavigationLink(destination: MeetingDetailView(meeting: meeting)) {
                MeetingRow(meeting: meeting)
            }
        }
    }
}

struct MeetingRow: View {
    let meeting: Meeting
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(meeting.title)
                    .font(.headline)
                
                Spacer()
                
                if meeting.isPrepReady == true {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                Text(meeting.startTime, style: .time)
                    .font(.subheadline)
                Text("•")
                    .font(.caption)
                Text(meeting.timeUntilDisplay)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .foregroundColor(.secondary)
            
            if !meeting.participants.isEmpty {
                HStack {
                    Image(systemName: "person.2")
                        .font(.caption)
                    Text("\(meeting.participants.count) participants")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MeetingDetailView: View {
    let meeting: Meeting
    
    var body: some View {
        List {
            Section("Details") {
                DetailRow(label: "Time", value: meeting.startTime.formatted(date: .abbreviated, time: .shortened))
                if let location = meeting.location {
                    DetailRow(label: "Location", value: location)
                }
                if let link = meeting.meetingLink {
                    Link("Join Meeting", destination: URL(string: link)!)
                        .font(.headline)
                }
            }
            
            if !meeting.participants.isEmpty {
                Section("Participants") {
                    ForEach(meeting.participants) { participant in
                        HStack {
                            Text(participant.displayName)
                            if participant.isOrganizer {
                                Text("(Organizer)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            if let description = meeting.description, !description.isEmpty {
                Section("Description") {
                    Text(description)
                }
            }
            
            Section("AI Prep") {
                NavigationLink {
                    TalkingPointsView(meeting: meeting)
                } label: {
                    Label(meeting.isPrepReady == true ? "View Talking Points" : "Generate Talking Points", systemImage: "sparkles")
                }
                
                Text("Readi will analyze your calendar, email context, and profile to craft personalized talking points.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .navigationTitle(meeting.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

struct EmptyMeetingsView: View {
    let onSync: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Upcoming Meetings")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Sync your calendar to see your meetings")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onSync) {
                Text("Sync Calendar")
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            List {
                if let user = authViewModel.currentUser {
                    Section("Account") {
                        DetailRow(label: "Email", value: user.email)
                        if let name = user.name {
                            DetailRow(label: "Name", value: name)
                        }
                    }
                    
                    if let profile = user.profile {
                        Section("Profile") {
                            DetailRow(label: "Role", value: profile.role.displayName)
                            if let displayName = profile.displayName {
                                DetailRow(label: "Preferred Name", value: displayName)
                            }
                            if let tz = profile.timeZone {
                                DetailRow(label: "Time Zone", value: tz)
                            }
                            if let reminder = profile.reminderMinutes {
                                DetailRow(label: "Reminder", value: "\(reminder) min before")
                            }
                            if let jobRole = profile.jobRole {
                                DetailRow(label: "Job Role", value: jobRole)
                            }
                            if let targets = profile.targetCompanies, !targets.isEmpty {
                                DetailRow(label: "Targets", value: targets.joined(separator: ", "))
                            }
                            if let company = profile.companyName {
                                DetailRow(label: "Company", value: company)
                            }
                            if let prefs = profile.preferredMeetingTypes, !prefs.isEmpty {
                                DetailRow(label: "Meeting Focus", value: prefs.joined(separator: ", "))
                            }
                            if let pitch = profile.productDescription, !pitch.isEmpty {
                                DetailRow(label: "Product", value: pitch)
                            }
                            if let pains = profile.salesPainPoints, !pains.isEmpty {
                                DetailRow(label: "Pain Points", value: pains)
                            }
                            if let targets = profile.salesTargets, !targets.isEmpty {
                                DetailRow(label: "Deal Focus", value: targets)
                            }
                            if let notification = profile.notificationPreference {
                                DetailRow(label: "Notifications", value: notification.capitalized)
                            }
                            if let notes = profile.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Sign Out", role: .destructive) {
                        authViewModel.logout()
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
