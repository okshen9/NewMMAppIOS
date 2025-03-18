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
    /// автор эвента
    let creatorExternalId: String?
    /// кому названем евент
    let assigneeExternalIds: [String]?
    /// сучноть к которой он привязан (паймент/таска/стрим) определяется по типу
    let issueId: Int?
    let description: String?
    /// дата для отображения
    let displayDate: String?
}
