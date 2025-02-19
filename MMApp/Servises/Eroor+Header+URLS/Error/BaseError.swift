//
//  BaseError.swift
//  MMApp
//
//  Created by artem on 18.02.2025.
//


/// Main API error type. Perfectly, all API errors should have this format
/// 
public struct BaseError: Codable, Equatable {
    public let code: Int?
    public let message: String?
    public let details: String?
}
