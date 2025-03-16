//
//  EventsRequestHelper.swift
//  MMApp
//
//  Created by artem on 08.03.2025.
//

enum EventsRequestHelper {
    case getEventById(id: Int)
    case updateEvent(id: Int)
    case getAllEvents
    case createEvent
    case searchEvents(searchParams: [EventsQuery.QueryValue])
    
    // MARK: - Query
    var query: EventsQueryBuilder? {
        switch self {
        case .searchEvents(let searchParams):
            return EventsQueryBuilder.searchEvents(searchParams: searchParams)
        default:
            return nil
        }
    }
    
    // MARK: - Путь
    var path: String {
        switch self {
        case .getEventById(let id):
            return "/events/\(id)"
        case .updateEvent(let id):
            return "/events/\(id)"
        case .getAllEvents:
            return "/events"
        case .createEvent:
            return "/events"
        case .searchEvents:
            return "/events/search"
        }
    }
    
    // MARK: - Метод
    var method: HTTPMethod {
        switch self {
        case .getEventById, .getAllEvents, .searchEvents:
            return .get
        case .updateEvent:
            return .put
        case .createEvent:
            return .post
        }
    }
}
