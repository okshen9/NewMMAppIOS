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

        var name: String {
            switch self {
            case .targetExpired: return Costants.Name.TARGET_EXPIRED.rawValue
            case .targetExpiredDone: return Costants.Name.TARGET_EXPIRED_DONE.rawValue
            case .targetDone: return Costants.Name.TARGET_DONE.rawValue
            case .targetInProgress: return Costants.Name.TARGET_IN_PROGRESS.rawValue
            case .anyValue(let value): return value
            }
        }

        init (rawValue: String) {
            switch rawValue {
            case Costants.Key.TARGET_EXPIRED: self = .targetExpired
            case Costants.Key.TARGET_EXPIRED_DONE: self = .targetExpiredDone
            case Costants.Key.TARGET_DONE: self = .targetDone
            case Costants.Key.TARGET_IN_PROGRESS: self = .targetInProgress
            default: self = .anyValue(rawValue)
            }
        }

        var rawValue: String {
            switch self {
            case .targetExpired: return Costants.Key.TARGET_EXPIRED
            case .targetExpiredDone: return Costants.Key.TARGET_EXPIRED_DONE
            case .targetDone: return Costants.Key.TARGET_DONE
            case .targetInProgress: return Costants.Key.TARGET_IN_PROGRESS
            case .anyValue(let value): return value
            }
        }

        enum Costants {
            enum Key {
                static let TARGET_EXPIRED = "TARGET_EXPIRED"
                static let TARGET_EXPIRED_DONE = "TARGET_EXPIRED_DONE"
                static let TARGET_DONE = "TARGET_DONE"
                static let TARGET_IN_PROGRESS = "TARGET_IN_PROGRESS"
            }

            enum Name: String {
                case TARGET_EXPIRED = "Цель просрочена"
                case TARGET_EXPIRED_DONE = "Цель завершена с просрочкой"
                case TARGET_DONE = "Цель завершена"
                case TARGET_IN_PROGRESS = "Цель в работе"
            }
        }
    }
}
