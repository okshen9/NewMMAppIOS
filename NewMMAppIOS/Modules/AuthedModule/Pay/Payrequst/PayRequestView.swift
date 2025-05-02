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
        NavigationView {
            VStack {
                if let payRequest = viewModel.payRequest, !viewModel.isLoading {
                    if payRequest.isEmpty {
                        Text("У вас нет платежей - все ок!")
                    }
                    List(payRequest, id: \.id) { payment in
                        PaymentRowView(payment: payment)
                    }
					
                    .listStyle(.plain)
                    .navigationTitle("Платежи")
					.refreshable {
						Task.detached {
							await viewModel.updateProfile()
						}
					}
                } else {
                    shimerState()
                }
            }
            .padding(.top, 6)
            .onAppear {
                viewModel.onApper()
            }
            .navigationTitle("Платежи")
        }
    }
    
    // MARK: - ViewBuilder
    @ViewBuilder
    func shimerState() -> some View {
        VStack(spacing: 20) {
			ShimmeringRectangle()
				.frame(height: 40)
				.cornerRadius(8)
				.padding(.top, 20)
			
			ShimmeringRectangle()
				.frame(height: 40)
				.cornerRadius(8)
				.padding(.top, 20)
            
			ShimmeringRectangle()
				.frame(height: 40)
				.cornerRadius(8)
				.padding(.top, 20)
            
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


