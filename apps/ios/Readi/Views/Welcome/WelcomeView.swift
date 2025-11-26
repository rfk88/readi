//
//  WelcomeView.swift
//  Readi
//
//  Created by Readi Team
//

import SwiftUI

struct WelcomeView: View {
    @Binding var hasSeenWelcome: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 24) {
                        // App Icon
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 80, weight: .light))
                            .foregroundStyle(.blue.gradient)
                            .symbolRenderingMode(.hierarchical)
                            .padding(.top, geometry.safeAreaInsets.top + 60)
                            .padding(.bottom, 8)
                        
                        // Title
                        Text("Welcome to Readi")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        // Subtitle
                        VStack(spacing: 12) {
                            Text("AI-powered meeting preparation")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text("Get personalized talking points and insights before every meeting")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 48)
                    
                    // Features Section
                    VStack(spacing: 24) {
                        FeatureRow(
                            icon: "envelope.fill",
                            title: "Email Analysis",
                            description: "Scans your emails for meeting context"
                        )
                        
                        FeatureRow(
                            icon: "calendar",
                            title: "Calendar Sync",
                            description: "Tracks your upcoming meetings"
                        )
                        
                        FeatureRow(
                            icon: "brain.head.profile",
                            title: "AI Insights",
                            description: "Generates personalized talking points"
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    
                    // Get Started Button
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            hasSeenWelcome = true
                        }
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.blue.gradient)
                            }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 32))
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon Container
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.blue)
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WelcomeView(hasSeenWelcome: .constant(false))
}

