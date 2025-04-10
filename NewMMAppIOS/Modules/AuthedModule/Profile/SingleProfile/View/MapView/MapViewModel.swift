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
    
    @Published var coordinateRaw: CLLocationCoordinate2D? = nil
    @Published var coordinatePoint: CLLocationCoordinate2D? = nil
    @Published var hasError: Bool = false
    
    init(nameCity: String, nameUser: String) {
        self.nameCity = nameCity
        self.nameUser = nameUser
    }
    
    /// Полчение координат города по названию
    func getCoordinates(for city: String? = nil) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city ?? nameCity) { [weak self] (placemarks, error) in
            if let location = placemarks?.first?.location {
                self?.coordinateRaw = CLLocationCoordinate2D(latitude: location.coordinate.latitude - 0.01, longitude: location.coordinate.longitude)
                self?.coordinatePoint = location.coordinate
            } else {
                self?.getCoordinates(for: "Москва")
                self?.hasError = true
            }
        }
    }
    
}
