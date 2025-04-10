//
//  SearchResponseDTO.swift
//  MMApp
//
//  Created by artem on 08.03.2025.
//

import Foundation

struct SearchResponseDTO: Codable {
    let results: [EventDTO]?
    let totalRecords: Int?
    let pageNumber: Int?
    let pageSize: Int?
}
