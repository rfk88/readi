//
//  TalkingPointsView.swift
//  Readi
//
//  Created by Readi Team
//

import SwiftUI

struct TalkingPointsView: View {
    let meeting: Meeting
    
    @State private var record: TalkingPointRecord?
    @State private var insights: [String] = []
    @State private var isGenerating = false
    @State private var isLoading = true
    @State private var statusMessage: String?
    
    private var talkingPoints: [String] {
        record?.points ?? []
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                contextSection
                talkingPointsSection
                insightsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .safeAreaInset(edge: .bottom) {
            generateButton
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .background(.thinMaterial)
        }
        .navigationTitle("Meeting Prep")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadTalkingPoints()
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(meeting.title)
                .font(.title3)
                .fontWeight(.semibold)
            Text(meeting.startTime.formatted(date: .abbreviated, time: .shortened))
                .foregroundColor(.secondary)
            if let generatedAt = record?.generatedAt {
                Text("Last generated \(generatedAt.formatted(date: .omitted, time: .shortened))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else if isLoading {
                ProgressView("Checking for prep…")
                    .font(.footnote)
            }
            
            if let status = statusMessage {
                Text(status)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var contextSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Context")
                .font(.headline)
            if let description = meeting.description, !description.isEmpty {
                Text(description)
            } else {
                Text("No meeting description provided.")
                    .foregroundColor(.secondary)
            }
            if !meeting.participants.isEmpty {
                Divider()
                Text("Participants")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                ForEach(meeting.participants.prefix(5)) { participant in
                    HStack {
                        Image(systemName: participant.isOrganizer ? "person.fill" : "person")
                            .foregroundColor(participant.isOrganizer ? .blue : .secondary)
                        Text(participant.displayName)
                    }
                    .font(.subheadline)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
    
    private var talkingPointsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Talking Points")
                .font(.headline)
            if talkingPoints.isEmpty {
                Text(isGenerating ? "Generating prep..." : "No prep yet. Tap Generate Prep to create AI suggestions.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(talkingPoints.enumerated()), id: \.offset) { index, point in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        Text(point)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Research & Insights")
                .font(.headline)
            if insights.isEmpty {
                Text("Readi will surface highlights from your inbox and public research here.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(insights, id: \.self) { insight in
                    Label(insight, systemImage: "lightbulb.fill")
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
    
    private var generateButton: some View {
        Button {
            Task {
                await generatePrep()
            }
        } label: {
            HStack {
                if isGenerating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "sparkles")
                    Text(talkingPoints.isEmpty ? "Generate Prep" : "Regenerate Prep")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isGenerating ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
        .disabled(isGenerating)
    }
    
    private func loadTalkingPoints() async {
        guard !isGenerating else { return }
        isLoading = true
        statusMessage = nil
        
        do {
            record = try await MeetingService.shared.getTalkingPoints(for: meeting.id)
            if record == nil {
                statusMessage = "No prep yet. Tap the button below to generate it."
            }
        } catch {
            statusMessage = "Could not load prep. Try generating it again."
        }
        
        isLoading = false
    }
    
    private func generatePrep() async {
        guard !isGenerating else { return }
        isGenerating = true
        statusMessage = nil
        
        do {
            let result = try await MeetingService.shared.generateTalkingPoints(for: meeting.id)
            record = result
            statusMessage = "Prep updated."
        } catch {
            statusMessage = "Something went wrong. Please try again."
        }
        
        isGenerating = false
    }
}

#Preview {
    let demoMeeting = Meeting(
        id: "demo",
        title: "Prep with Acme Corp",
        description: "Discuss pipeline blockers and next pilot.",
        startTime: Date().addingTimeInterval(3600),
        endTime: Date().addingTimeInterval(5400),
        location: "Zoom",
        meetingLink: "https://example.com",
        status: "confirmed",
        participants: [
            MeetingParticipant(id: "1", email: "sam@example.com", name: "Sam Lee", isOrganizer: true, responseStatus: "accepted"),
            MeetingParticipant(id: "2", email: "jordan@example.com", name: "Jordan Rivera", isOrganizer: false, responseStatus: "accepted")
        ],
        minutesUntilStart: 60,
        hoursUntilStart: 1,
        isPrepReady: false
    )
    
    return NavigationStack {
        TalkingPointsView(meeting: demoMeeting)
    }
}

