//
//  EventsResultModel.swift
//  MMApp
//
//  Created by artem on 08.03.2025.
//

import Foundation

struct EventDTO: Codable, JSONRepresentable {
    let id: Int?
    let title: String?
    let startDate: String?
    let endDate: String?
    let type: String?
    let creatorExternalId: String?
    let assigneeExternalIds: [String]?
    let issueId: Int?
    let description: String?
}
