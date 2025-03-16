//
//  EventsQueryBuilder.swift
//  MMApp
//
//  Created by artem on 08.03.2025.
//

import Foundation

enum EventsQueryBuilder: QueryItemsRepresentable {
    // MARK: - Кейсы
    /// получение данных
    case searchEvents(searchParams: [EventsQuery.QueryValue])

    // MARK: Query
    var query: EventsQueryBuilder? {
        switch self {
        case let .searchEvents(searchParams):
            return EventsQueryBuilder.searchEvents(searchParams: searchParams)
        default:
            return nil
        }
    }
    
    // MARK: Путь
    func queryItems() -> [URLQueryItem] {
        var items = [URLQueryItem]()
        
        switch self {
        case let .searchEvents(searchParams):
            searchParams.forEach { searchParam in
                switch searchParam {
                case .type(let typeEvents):
                    let typeEventsStr = typeEvents.map{$0.rawValue}.joined(separator: ",")
                        items.append(URLQueryItem(name: searchParam.rawValue, value: typeEventsStr))
                case .id(let val):
                    items.append(URLQueryItem(name: searchParam.rawValue, value: val))
                case .title(let val):
                    items.append(URLQueryItem(name: searchParam.rawValue, value: val))
                case .startDate(let val):
                    items.append(URLQueryItem(name: searchParam.rawValue, value: val))
                case .endDate(let val):
                    items.append(URLQueryItem(name: searchParam.rawValue, value: val))
                case .creatorExternalId(let val):
                    items.append(URLQueryItem(name: searchParam.rawValue, value: val))
                case .assigneeExternalIds(let ids):
                    let isdStr = ids.joined(separator: ",")
                    items.append(URLQueryItem(name: searchParam.rawValue, value: isdStr))
                case .issueId(let val):
                    items.append(URLQueryItem(name: searchParam.rawValue, value: val))
                }
            }
            return items
        default:
            return items
        }
    }
}

struct EventsQuery {
    enum QueryValue: Hashable {
        /// id event
        case id(String)
        /// навзаени
        case title(String)
        /// дата начала
        case startDate(String)
        /// дата конца
        case endDate(String)
        /// тип эвентов
        case type([EventsType])
        /// id автора
        case creatorExternalId(String)
        /// кого косаются эвенты
        case assigneeExternalIds([String])
        /// id сущности, к которой привязан эвент
        case issueId(String)
        
        
        var rawValue: String {
            switch self {
                /// id event
            case .id: return "id"
                /// навзаени
            case .title: return "title"
                /// дата начала
            case .startDate: return "startDate"
                /// дата конца
            case .endDate: return "endDate"
                /// тип эвентов
            case .type(let types): return "type"
                /// id автора
            case .creatorExternalId: return "creatorExternalId"
                /// кого косаются эвенты
            case .assigneeExternalIds(let externalIds): return "assigneeExternalIds"
                /// id сущности, к которой привязан эвент
            case .issueId: return "issueId"
            }
        }
    }
    
    enum EventsType: Hashable {
        case targetExpired
        case targetExpiredDone
        case targetDone
        case targetInProgress
        case anyValue(String)
        
        init (rawValue: String) {
            switch rawValue {
                case "TARGER_EXPIRED": self = .targetExpired
            case "TARGER_EXPIRED_DONE": self = .targetExpiredDone
            case "TARGER_DONE": self = .targetDone
            case "TARGER_IN_PROGRESS": self = .targetInProgress
            default: self = .anyValue(rawValue)
            }
        }
        
        var rawValue: String {
            switch self {
            case .targetExpired: return "TARGER_EXPIRED"
            case .targetExpiredDone: return "TARGER_EXPIRED_DONE"
            case .targetDone: return "TARGER_DONE"
            case .targetInProgress: return "TARGER_IN_PROGRESS"
            case .anyValue(let value): return value
            }
        }
    }
}
