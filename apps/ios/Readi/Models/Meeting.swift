//
//  Meeting.swift
//  Readi
//
//  Created by Readi Team
//

import Foundation

struct Meeting: Codable, Identifiable {
    let id: String
    let title: String
    let description: String?
    let startTime: Date
    let endTime: Date
    let location: String?
    let meetingLink: String?
    let status: String
    let participants: [MeetingParticipant]
    let minutesUntilStart: Int?
    let hoursUntilStart: Int?
    let isPrepReady: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, location, status, participants
        case startTime = "start_time"
        case endTime = "end_time"
        case meetingLink = "meeting_link"
        case minutesUntilStart = "minutesUntilStart"
        case hoursUntilStart = "hoursUntilStart"
        case isPrepReady
    }
    
    var timeUntilDisplay: String {
        guard let minutes = minutesUntilStart else { return "" }
        
        if minutes < 0 {
            return "In progress"
        } else if minutes < 60 {
            return "in \(minutes)m"
        } else if let hours = hoursUntilStart {
            if hours < 24 {
                return "in \(hours)h"
            } else {
                let days = hours / 24
                return "in \(days)d"
            }
        }
        return ""
    }
}

struct MeetingParticipant: Codable, Identifiable {
    let id: String
    let email: String
    let name: String?
    let isOrganizer: Bool
    let responseStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email, name
        case isOrganizer = "is_organizer"
        case responseStatus = "response_status"
    }
    
    var displayName: String {
        name ?? email
    }
}

struct MeetingsResponse: Codable {
    let meetings: [Meeting]
    let count: Int
}

