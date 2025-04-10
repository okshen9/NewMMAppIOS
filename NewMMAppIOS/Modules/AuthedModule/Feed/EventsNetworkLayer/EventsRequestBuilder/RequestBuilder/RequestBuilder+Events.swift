//
//  RequestBuilder+Events.swift
//  MMApp
//
//  Created by artem on 08.03.2025.
//

import Foundation

extension APIFactory: EventsRequestProtocol {
    func getEventByIdRequest(id: Int) throws -> URLRequest {
        let helper = EventsRequestHelper.getEventById(id: id)
        let url = try urlBuilder.buildURL(path: helper.path)
        return try requestBuilder.buildURLRequest(
            url: url,
            query: helper.query,
            method: helper.method,
            tokenNeccessity: .mandatory
        )
    }
    
    func updateEventRequest(id: Int, model: EventDTO) throws -> URLRequest {
        let helper = EventsRequestHelper.updateEvent(id: id)
        let url = try urlBuilder.buildURL(path: helper.path)
        return try requestBuilder.buildJSONParamsRequest(
            url: url,
            bodyModel: model,
            query: helper.query,
            method: helper.method,
            tokenNeccessity: .mandatory
        )
    }
    
    func getAllEventsRequest() throws -> URLRequest {
        let helper = EventsRequestHelper.getAllEvents
        let url = try urlBuilder.buildURL(path: helper.path)
        return try requestBuilder.buildURLRequest(
            url: url,
            query: helper.query,
            method: helper.method,
            tokenNeccessity: .mandatory
        )
    }
    
    func createEventRequest(model: EventDTO) throws -> URLRequest {
        let helper = EventsRequestHelper.createEvent
        let url = try urlBuilder.buildURL(path: helper.path)
        return try requestBuilder.buildJSONParamsRequest(
            url: url,
            bodyModel: model,
            query: helper.query,
            method: helper.method,
            tokenNeccessity: .mandatory
        )
    }
    
    func searchEventsRequest(searchParams: [EventsQuery.QueryValue]) throws -> URLRequest {
        let helper = EventsRequestHelper.searchEvents(searchParams: searchParams)
        let url = try urlBuilder.buildURL(path: helper.path)
        return try requestBuilder.buildURLRequest(
            url: url,
            query: helper.query,
            method: helper.method,
            tokenNeccessity: .mandatory
        )
    }
}
