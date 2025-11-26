//
//  MeetingService.swift
//  Readi
//
//  Created by Readi Team
//

import Foundation

struct MeetingResponse: Codable {
    let meeting: Meeting
}

struct TalkingPointRecord: Codable, Identifiable {
    let id: String
    let meetingId: String
    let points: [String]
    let aiModel: String
    let generatedAt: Date
    let feedback: String?
}

struct TalkingPointResponse: Codable {
    let talkingPoints: TalkingPointRecord?
}

struct EmptyResponse: Codable {}

class MeetingService {
    static let shared = MeetingService()
    private init() {}
    
    private let apiClient = APIClient.shared
    
    func syncCalendar() async throws {
        struct SyncResponse: Codable {
            let message: String
            let synced: Int
        }
        let _: SyncResponse = try await apiClient.post("/meetings/sync")
    }
    
    func getUpcomingMeetings(limit: Int = 20) async throws -> [Meeting] {
        let response: MeetingsResponse = try await apiClient.get("/meetings/upcoming?limit=\(limit)")
        return response.meetings
    }
    
    func getMeeting(id: String) async throws -> Meeting {
        let response: MeetingResponse = try await apiClient.get("/meetings/\(id)")
        return response.meeting
    }
    
    func generateTalkingPoints(for meetingId: String) async throws -> TalkingPointRecord {
        let response: TalkingPointResponse = try await apiClient.post("/meetings/\(meetingId)/generate-prep")
        guard let record = response.talkingPoints else {
            throw APIError.invalidResponse
        }
        return record
    }
    
    func getTalkingPoints(for meetingId: String) async throws -> TalkingPointRecord? {
        let response: TalkingPointResponse = try await apiClient.get("/meetings/\(meetingId)/talking-points")
        return response.talkingPoints
    }
    
    func submitTalkingPointFeedback(for meetingId: String, feedback: String?, notes: String?) async throws {
        struct FeedbackPayload: Codable {
            let feedback: String?
            let notes: String?
        }
        
        let _: EmptyResponse = try await apiClient.post(
            "/meetings/\(meetingId)/feedback",
            body: FeedbackPayload(feedback: feedback, notes: notes)
        )
    }
}

