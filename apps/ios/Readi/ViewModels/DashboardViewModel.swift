//
//  DashboardViewModel.swift
//  Readi
//
//  Created by Readi Team
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var meetings: [Meeting] = []
    @Published var isLoading = false
    @Published var isSyncing = false
    @Published var error: String?
    
    private let meetingService = MeetingService.shared
    
    func loadMeetings() async {
        isLoading = true
        error = nil
        
        do {
            meetings = try await meetingService.getUpcomingMeetings()
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func syncCalendar() async {
        isSyncing = true
        error = nil
        
        do {
            try await meetingService.syncCalendar()
            await loadMeetings()
        } catch {
            self.error = error.localizedDescription
        }
        
        isSyncing = false
    }
    
    func refresh() async {
        await loadMeetings()
    }
}

