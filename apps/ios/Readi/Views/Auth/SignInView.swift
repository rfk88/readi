//
//  SignInView.swift
//  Readi
//
//  Created by Readi Team
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Logo and title
            VStack(spacing: 16) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Readi")
                    .font(.system(size: 48, weight: .bold))
                
                Text("AI-powered meeting preparation")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Sign in button
            VStack(spacing: 16) {
                Button {
                    Task {
                        await authViewModel.signInWithGoogle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.circle.fill")
                        Text("Sign in with Google")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(authViewModel.isLoading)
                
                if authViewModel.isLoading {
                    ProgressView()
                }
                
                if let error = authViewModel.error {
                    VStack(spacing: 8) {
                        Text("Error")
                            .font(.headline)
                            .foregroundColor(.red)
                        ScrollView {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .frame(maxHeight: 200)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
        .padding()
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
}

