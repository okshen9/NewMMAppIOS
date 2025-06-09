//
//  ProfileTargetView.swift
//  NewMMAppIOS
//
//  Created by artem on 20.04.2025.
//

import SwiftUI

struct ProfileTargetView: View {
    @StateObject private var viewModel: ProfileTargetViewModel

    init(externalId: Int) {
        _viewModel = StateObject(wrappedValue: ProfileTargetViewModel(externalId: externalId))
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                shimerState()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            if let targets = viewModel.targetsByCategory[category], !targets.isEmpty {
                                CategorySectionView(
                                    myTarget: viewModel.canEdit,
                                    category: category,
                                    targets: targets,
                                    onEdit: {
//                                        selectedCategory = category
//                                        isEditingCategory = true
                                    }
                                )
                            } else {
                                emptyStateView()
                            }
                        }
                    }
                    .padding()
                }
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

    @ViewBuilder
    private func categorySectionView(for category: TargetCategory) -> some View {
        if let filtredTarget = viewModel.targetsByCategory[category],
            !filtredTarget.isEmpty {
            CategorySectionView(
                category: category,
                targets: filtredTarget,
                onEdit: {
//                    selectedCategory = category
//                    isEditingCategory = true
                }
            )
        }
    }
    
    @ViewBuilder
    private func emptyStateView() -> some View {
        VStack {
            Spacer()
            Image(systemName: "list.star")
                .font(.system(size: 66))
                .foregroundColor(.mainRed)
                .padding(.bottom, 20)
            
            Text("У пользователя пока нет целей")
                .font(MMFonts.title)
                .foregroundColor(.headerText)
                .padding(.bottom, 4)
            
            Text("Как только человек создаст цели вы сможете увидеть их")
                .font(MMFonts.subTitle)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding()
    }
}

