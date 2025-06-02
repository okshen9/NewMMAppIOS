//
//  EventsResultModel.swift
//  MMApp
//
//  Created by artem on 08.03.2025.
//

import Foundation

struct EventDTO: Codable, JSONRepresentable, Identifiable {
    let id: Int?
    let title: String?
    let startDate: String?
    let endDate: String?
    let type: EventType?
    /// автор эвента
    let creatorExternalId: String?
    /// кому названем евент
    let assigneeExternalIds: [String]?
    /// сучноть к которой он привязан (паймент/таска/стрим) определяется по типу
    let issueId: Int?
    let description: String?
    /// дата для отображения
    let displayDate: String?

    let userProfile: UserProfileResultDto?
    let hidden: Bool?

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.startDate = try container.decodeIfPresent(String.self, forKey: .startDate)
        self.endDate = try container.decodeIfPresent(String.self, forKey: .endDate)
        self.type = try container.decodeIfPresent(EventType.self, forKey: .type)
        self.creatorExternalId = try container.decodeIfPresent(String.self, forKey: .creatorExternalId)
        self.assigneeExternalIds = try container.decodeIfPresent([String].self, forKey: .assigneeExternalIds)
        self.issueId = try container.decodeIfPresent(Int.self, forKey: .issueId)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.displayDate = try container.decodeIfPresent(String.self, forKey: .displayDate)
        self.userProfile = try container.decodeIfPresent(UserProfileResultDto.self, forKey: .userProfile)
        self.hidden = try container.decodeIfPresent(Bool.self, forKey: .hidden)
    }

    init(id: Int?, title: String?, startDate: String?, endDate: String?, type: EventType?, creatorExternalId: String?, assigneeExternalIds: [String]?, issueId: Int?, description: String?, displayDate: String?, userProfile: UserProfileResultDto?, hidden: Bool?) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.creatorExternalId = creatorExternalId
        self.assigneeExternalIds = assigneeExternalIds
        self.issueId = issueId
        self.description = description
        self.displayDate = displayDate
        self.userProfile = userProfile
        self.hidden = hidden
    }
}

extension EventDTO {
    static func getTextEvent(for type: EventType) -> EventDTO {
        .init(
            id: 1,
            title: "Взял в аренду Porshe прокатился по Питеру и ещё +1 машину",
            startDate: "2025-04-06T13:45:55.772694",
            endDate: "2025-04-30T23:59:59.999",
            type: type,
            creatorExternalId: "1",
            assigneeExternalIds: ["1"],
            issueId: 1,
            description: "3 тренировки в неделю в спортзале",
            displayDate: "2025-04-06T13:45:55.772694",
            userProfile: UserProfileResultDto.getTestUser(),
            hidden: false
        )
    }
}

