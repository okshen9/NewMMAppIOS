//
//  PortfolioSliceData.swift
//  MMApp
//
//  Created by artem on 05.02.2025.
//

import SwiftUI

struct PortfolioSliceData {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
    var strongColor: Color
}

struct PortfolioStatisticSlice: View {
    var portfolioSliceData: PortfolioSliceData
    
    var midRadians: Double {
        return Double.pi / 2.0 - (portfolioSliceData.startAngle + portfolioSliceData.endAngle).radians / 2.0
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                Path { path in
                    let width: CGFloat = min(geometry.size.width, geometry.size.height)
                    let height = width
                    path.move(
                        to: CGPoint(
                            x: width * 0.5,
                            y: height * 0.5
                        )
                    )
                    path.addArc(center: CGPoint(x: width * 0.5, y: height * 0.5), radius: width * 0.5, startAngle: Angle(degrees: -90.0) + portfolioSliceData.startAngle, endAngle: Angle(degrees: -90.0) + portfolioSliceData.endAngle, clockwise: false)
                    
                }
                .fill(portfolioSliceData.color)
            }
            .frame(alignment: .center)
            
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

//struct PortfolioStatisticSlice_Previews: PreviewProvider {
//    static var previews: some View {
//        PortfolioStatisticSlice(portfolioSliceData: PortfolioSliceData(startAngle: Angle(degrees: 0.0), endAngle: Angle(degrees: 120.0), color: Color.black, strongColor: Color.black))
//    }
//}
