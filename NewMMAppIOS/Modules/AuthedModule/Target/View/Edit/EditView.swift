//
//  EditView.swift
//  MMApp
//
//  Created by artem on 30.01.2025.
//

import SwiftUI

struct EditView: View {
    let title: String
    let actions: [Action]
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(actions, id: \.title) { action in
                Button(action: action.handler) {
                    HStack {
                        Text(action.title)
                        Spacer()
                        if action.isDestructive {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarItems(trailing: Button("Готово") { isPresented = false })
        }
    }
}

struct Action {
    let title: String
    let handler: () -> Void
    let isDestructive: Bool
}
