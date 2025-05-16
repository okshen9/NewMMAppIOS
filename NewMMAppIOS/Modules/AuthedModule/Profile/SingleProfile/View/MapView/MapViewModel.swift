//
//  MapViewModel.swift
//  MMApp
//
//  Created by artem on 03.03.2025.
//

import Foundation
import CoreLocation

final class MapViewModel: ObservableObject {
    let nameCity: String
    let nameUser: String

    var cityForDisplay: String {
        hasError ? "Москва" : nameCity
    }
    
    // Флаг для контроля качества карты
    @Published var highQualityEnabled = false

    @Published var coordinateRaw: CLLocationCoordinate2D? = nil
    @Published var coordinatePoint: CLLocationCoordinate2D? = nil
    @Published var hasError: Bool = false
    
    // Очередь для операций с геокодированием
    private let geocoderQueue = DispatchQueue(label: "com.mmapp.geocoder", qos: .userInitiated)
    
    init(nameCity: String, nameUser: String) {
        self.nameCity = nameCity
        self.nameUser = nameUser
    }
    
    /// Полчение координат города по названию
    func getCoordinates(for city: String? = nil) async {
        // Защита от повторных запросов, если координаты уже есть
        if coordinateRaw != nil && coordinatePoint != nil {
            return
        }
        
        // Запускаем запрос на выделенной очереди
        return await withCheckedContinuation { continuation in
            geocoderQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume()
                    return
                }
                
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(city ?? self.nameCity) { [weak self] (placemarks, error) in
                    guard let self = self else {
                        continuation.resume()
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if let location = placemarks?.first?.location {
                            self.coordinateRaw = CLLocationCoordinate2D(
                                latitude: location.coordinate.latitude - 0.01,
                                longitude: location.coordinate.longitude
                            )
                            self.coordinatePoint = location.coordinate
                            continuation.resume()
                        } else {
                            if city != "Москва" {
                                Task {
                                    await self.getCoordinates(for: "Москва")
                                }
                            }
                            self.hasError = true
                            continuation.resume()
                        }
                    }
                }
            }
        }
    }
}
