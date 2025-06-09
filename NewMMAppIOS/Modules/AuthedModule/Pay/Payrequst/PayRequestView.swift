//
//  PayRequestView.swift
//  MMApp
//
//  Created by artem on 23.02.2025.
//

import SwiftUI

struct PayRequestView: View {
	@StateObject var viewModel = PayRequestViewModel()
	
	var body: some View {
        NavigationView {
            VStack {
                if let payRequest = viewModel.payRequest, !viewModel.isLoading, !payRequest.isEmpty {
						paymentList(payRequest)
                } else {
                    ScrollView {
                        if !viewModel.isLoading {
                            emptyPayment
                        } else {
                            shimerState()
                        }
                    }
                    .refreshable {
                        if !viewModel.isLoading {
                            Task.detached {
                                await viewModel.updateProfile()
                            }
                        }
                    }
                    
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
	fileprivate func shimerState() -> some View {
        VStack(spacing: 16) {
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
	
	@ViewBuilder
	fileprivate var emptyPayment: some View {
		VStack(spacing: 16) {
			Image(systemName: "checkmark.circle")
				.font(.system(size: 80))
				.foregroundColor(.green)
				.padding(.bottom, 16)
			
			Text("У вас нет платежей")
				.font(MMFonts.title)
				.foregroundColor(.headerText)
				.fontWeight(.bold)
			
			Text("Можно спать спокойно")
				.font(MMFonts.body)
				.foregroundColor(.headerText)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 32)
			
			Spacer()
		}
		.padding(.top, 80)
		.frame(maxWidth: .infinity)
	}
	
	@ViewBuilder
	fileprivate func paymentList(_ payRequest: [PaymentRequestResponseDto]) -> some View {
		List(payRequest, id: \.id) { payment in
			PaymentRowView(payment: payment)
				.listRowSeparator(.hidden)
		}
		.listRowSpacing(-12)
		.listStyle(.plain)
		.refreshable {
			Task.detached {
				await viewModel.updateProfile()
			}
		}
	}
}

