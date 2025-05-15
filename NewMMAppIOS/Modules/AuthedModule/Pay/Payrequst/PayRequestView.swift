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
                if let payRequest = viewModel.payRequest, !viewModel.isLoading {
					if true {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 80))
                                .foregroundColor(.green)
                                .padding(.bottom, 16)
                            
                            Text("У вас нет платежей")
                                .font(.title2)
								.foregroundColor(.headerText)
                                .fontWeight(.bold)
                            
                            Text("Можно спать спокойно")
                                .font(.body)
								.foregroundColor(.headerText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Spacer()
                        }
                        .padding(.top, 80)
                        .frame(maxWidth: .infinity)
                    } else {
                        List(payRequest, id: \.id) { payment in
                            PaymentRowView(payment: payment)
                        }
                        .listStyle(.plain)
                        .listRowSeparator(.hidden)
						.refreshable {
							Task.detached {
								await viewModel.updateProfile()
							}
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
	@Previewable @StateObject var viewModel = PayRequestViewModel()
	viewModel.payRequest = .init()
	viewModel.isLoading = false
	return PayRequestView(viewModel: viewModel)
}


#Preview("2") {
	Text("У вас нет платежей")
		.font(.title2)
		.fontWeight(.bold)
		.foregroundColor(.secondary)
}

