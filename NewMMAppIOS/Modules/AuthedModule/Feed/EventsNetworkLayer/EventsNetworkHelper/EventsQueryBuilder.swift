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
                case .pageNumberPagination(let pageNumber):
                    items.append(URLQueryItem(name: searchParam.rawValue, value: pageNumber))
                case .pageSizePagination(let pageSize):
                    items.append(URLQueryItem(name: searchParam.rawValue, value: pageSize))
                case .sortDisplayDate(let typeSort):
                    items.append(URLQueryItem(name: searchParam.rawValue, value: typeSort.rawValue))
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
        case type([EventType])
        /// id автора
        case creatorExternalId(String)
        /// кого косаются эвенты
        case assigneeExternalIds([String])
        /// id сущности, к которой привязан эвент
        case issueId(String)
        /// номер страницы пагинации
        case pageNumberPagination(String)
        /// размер страницы
        case pageSizePagination(String)
        /// сортировка
        case sortDisplayDate(SortType = .DESC)

        
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
                /// номер страницы пагианации
            case .pageNumberPagination(let page):
                return "pageNumber"
                /// количество элементов в странице
            case .pageSizePagination(let size):
                return "pageSize"
                /// сортировка по отображемой дате
            case .sortDisplayDate:
                return "sort_displayDate"
            }
        }
    }
}

enum SortType: String, CaseIterable {
    /// по возврастания
    case ASK = "ASK"
    /// по убыванию
    case DESC = "DESC"
}
