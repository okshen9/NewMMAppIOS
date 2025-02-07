//
//  StatisticTargetScreen.swift
//  MMApp
//
//  Created by artem on 06.02.2025.
//

import SwiftUI

struct StatisticTargetScreen: View {
    var body: some View {
        VStack {
            HStack {
                PiaView(values: [50, 30, 40])
                Text("test")
            }
        }
    }
}

#Preview {
    StatisticTargetScreen()
}
