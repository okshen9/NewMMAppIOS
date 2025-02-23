//
//  PayRequestView.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import SwiftUI

struct PayRequestView: View {
    @StateObject private var viewModel = PayRequestViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                shimerState()
            } else {
                Text("isLoading: \(viewModel.isLoading)")
            }
        }
        .onAppear {
            viewModel.onApper()
        }
    }
    
    // MARK: - ViewBuilder
    @ViewBuilder
    func shimerState() -> some View {
        VStack(spacing: 20) {
            ShimmeringRectangle()
                .frame(width: 88, height: 88)
                .cornerRadius(44)
            
            ShimmeringRectangle()
                .frame(height: 20)
                .cornerRadius(8)
            
            ShimmeringRectangle()
                .frame(height: 20)
                .cornerRadius(8)
                .padding(.horizontal, 40)
            
            ShimmeringRectangle()
                .frame(height: 40)
                .cornerRadius(8)
                .padding(.top, 20)
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    PayRequestView()
}
