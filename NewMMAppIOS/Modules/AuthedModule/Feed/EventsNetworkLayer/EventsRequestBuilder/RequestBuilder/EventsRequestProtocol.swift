//
//  EventsRequestProtocol.swift
//  MMApp
//
//  Created by artem on 08.03.2025.
//

import Foundation

protocol EventsRequestProtocol {
    /// Получить событие по ID
    /// - Parameter id: ID события
    /// - Returns: Подготовленный запрос
    func getEventByIdRequest(id: Int) throws -> URLRequest
    
    /// Обновить событие
    /// - Parameters:
    ///   - id: ID события
    ///   - model: Модель данных события
    /// - Returns: Подготовленный запрос
    func updateEventRequest(id: Int, model: EventDTO) throws -> URLRequest
    
    /// Получить все события
    /// - Returns: Подготовленный запрос
    func getAllEventsRequest() throws -> URLRequest
    
    /// Создать новое событие
    /// - Parameter model: Модель данных события
    /// - Returns: Подготовленный запрос
    func createEventRequest(model: EventDTO) throws -> URLRequest
    
    /// Поиск событий по параметрам
    /// - Parameter searchParams: Параметры поиска (ключ-значение)
    /// - Returns: Подготовленный запрос
    func searchEventsRequest(searchParams: [EventsQuery.QueryValue]) throws -> URLRequest
}
