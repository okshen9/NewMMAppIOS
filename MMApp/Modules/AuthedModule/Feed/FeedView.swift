//
//  FeedView.swift
//  MMApp
//
//  Created by artem on 13.03.2025.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    VStack {
                        if viewModel.isLoading {
                            shimerState()
                        } else {

                            Text("У вас пока нет новостей")
                            ForEach(viewModel.feedEvents ?? []) { event in

                                //                                let title = event.type
                                FeedCell(
                                    type: .task,
                                    title: event.title.orEmpty,
                                    subtitle: event.description.orEmpty,
                                    date: event.displayDate ?? Date().toApiString)
                            }

                        }
                    }
                }
            }

            .onAppear {
                viewModel.onApper()
            }
            .navigationTitle("Новости")
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
    FeedView()
}
