//
//  APIClient.swift
//  Readi
//
//  Created by Readi Team
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, let message):
            return message ?? "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized. Please sign in again."
        }
    }
}

struct ErrorResponse: Codable {
    let error: ErrorDetail
    
    struct ErrorDetail: Codable {
        let code: String
        let message: String
    }
}

class APIClient {
    static let shared = APIClient()
    
    // Use Mac's IP address for real device testing, localhost for simulator
    #if targetEnvironment(simulator)
    private let baseURL = "http://127.0.0.1:4000/api/v1"
    #else
    private let baseURL = "http://192.168.70.198:4000/api/v1"
    #endif
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Prisma returns dates in ISO8601 format with fractional seconds
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try with fractional seconds first
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            // Fallback to standard ISO8601
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }
        return decoder
    }()
    
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    private init() {}
    
    // MARK: - Request Methods
    
    func get<T: Decodable>(_ endpoint: String) async throws -> T {
        try await request(endpoint, method: "GET")
    }
    
    func post<T: Decodable>(_ endpoint: String, body: Encodable? = nil) async throws -> T {
        try await request(endpoint, method: "POST", body: body)
    }
    
    func put<T: Decodable>(_ endpoint: String, body: Encodable? = nil) async throws -> T {
        try await request(endpoint, method: "PUT", body: body)
    }
    
    func delete<T: Decodable>(_ endpoint: String) async throws -> T {
        try await request(endpoint, method: "DELETE")
    }
    
    // MARK: - Core Request
    
    private func request<T: Decodable>(
        _ endpoint: String,
        method: String,
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if available
        if let token = KeychainManager.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add body if present
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Handle error responses
            if httpResponse.statusCode >= 400 {
                if httpResponse.statusCode == 401 {
                    throw APIError.unauthorized
                }
                
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                    throw APIError.httpError(
                        statusCode: httpResponse.statusCode,
                        message: errorResponse.error.message
                    )
                }
                
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: nil)
            }
            
            // Decode successful response
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                // Log the raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("❌ Failed to decode response. Raw JSON:\n\(jsonString)")
                }
                print("❌ Decoding error: \(error)")
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

