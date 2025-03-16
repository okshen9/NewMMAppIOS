//
//  ServiceBuilder+Events.swift
//  MMApp
//
//  Created by artem on 08.03.2025.
//

import Foundation

extension ServiceBuilder: EventsServiceProtocol {
    func getEventById(id: Int) async throws -> EventDTO {
        try await performRequest {
            try apiFactory.getEventByIdRequest(id: id)
        }
    }
    
    func updateEvent(id: Int, model: EventDTO) async throws -> EventDTO {
        try await performRequest {
            try apiFactory.updateEventRequest(id: id, model: model)
        }
    }
    
    func getAllEvents() async throws -> [EventDTO] {
        try await performRequest {
            try apiFactory.getAllEventsRequest()
        }
    }
    
    func createEvent(model: EventDTO) async throws -> EventDTO {
        try await performRequest {
            try apiFactory.createEventRequest(model: model)
        }
    }
    
    func searchEvents(searchParams: [EventsQuery.QueryValue]) async throws -> SearchResponseDTO {
        try await performRequest {
            try apiFactory.searchEventsRequest(searchParams: searchParams)
        }
    }
}
