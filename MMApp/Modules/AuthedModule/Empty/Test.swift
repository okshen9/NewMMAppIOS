//
//  Test.swift
//  MMApp
//
//  Created by artem on 04.02.2025.
//

import Foundation
import SwiftUI

struct TestView: View {
    var body: some View {
                VStack {
                    GeometryReader {_ in
                        PiaView(values: [10, 30])
                            .background(.green)
                    }
                }
//        VStack {
//            GeometryReader { geometry in
//                VStack {
//                    Text("Этот текст отображается по центру")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                    
//                }
//                .frame(
//                    width: geometry.size.width,
//                    height: geometry.size.height,
//                    alignment: .center) // Центрируем по центру GeometryReader
//                .background(Color.red)
//            }
//            .background(Color.green) // Фон для наглядности
//        }
        
    }
}


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
