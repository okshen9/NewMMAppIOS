//
//  MapView.swift
//  MMApp
//
//  Created by artem on 03.03.2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    var canInteactive: Bool {
        didSet {

        }
    }
    var withSgift = true
    @StateObject var viewModel: MapViewModel
    
    var body: some View {
        GeometryReader { geometry in
            if let coordinateRaw = viewModel.coordinateRaw,
               let coordinatePoint = viewModel.coordinatePoint {
                let region = MKCoordinateRegion(
                    center: coordinateRaw,
                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                )
                
                Map(position: .constant(.region(region)),
                    interactionModes: canInteactive ? [.pitch, .zoom] : [])
                {
                    Annotation("\(viewModel.cityForDisplay)\n\(viewModel.nameUser)",
                               coordinate: withSgift ? coordinatePoint : coordinateRaw)
                    {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .font(MMFonts.title)
                    }
                }
                .frame(width: geometry.size.width,
                       height: geometry.size.height)
                .cornerRadius(20)
//            } else if viewModel.hasError {
//                Text("Не удалось найти город")
            } else {
                ShimmeringRectangle()
                    .frame(width: geometry.size.width,
                           height: geometry.size.height)
                    .cornerRadius(20)
                
            }
        }
        .onAppear {
            Task {
                viewModel.getCoordinates()
            }
        }
    }
    
}

#Preview {
    MapView(canInteactive: true, viewModel: .init(nameCity: "Саратов", nameUser: "Артем"))
        .frame(height: 200)
}
