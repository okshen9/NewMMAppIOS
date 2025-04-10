//
//  EventsServiceProtocol.swift
//  MMApp
//
//  Created by artem on 08.03.2025.
//

import Foundation

protocol EventsServiceProtocol {
    /// Получить событие по ID
    /// - Parameter id: ID события
    /// - Returns: Модель события
    func getEventById(id: Int) async throws -> EventDTO
    
    /// Обновить событие
    /// - Parameters:
    ///   - id: ID события
    ///   - model: Модель данных события
    /// - Returns: Обновленная модель события
    func updateEvent(id: Int, model: EventDTO) async throws -> EventDTO
    
    /// Получить все события
    /// - Returns: Массив моделей событий
    func getAllEvents() async throws -> [EventDTO]
    
    /// Создать новое событие
    /// - Parameter model: Модель данных события
    /// - Returns: Созданная модель события
    func createEvent(model: EventDTO) async throws -> EventDTO
    
    /// Поиск событий по параметрам
    /// - Parameter searchParams: Параметры поиска (ключ-значение)
    /// - Returns: Результат поиска
    func searchEvents(searchParams: [EventsQuery.QueryValue]) async throws -> SearchResponseDTO
}
