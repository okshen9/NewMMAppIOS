//
//  SearchResponseDTO.swift
//  MMApp
//
//  Created by artem on 08.03.2025.
//

import Foundation

struct SearchResponseDTO: Codable, PaginationProtocol {
    var results: [EventDTO]?
    var totalRecords: Int?
    var pageNumber: Int?
    var pageSize: Int?
}
