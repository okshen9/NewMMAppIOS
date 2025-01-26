//
//  ContentView9.swift
//  MMApp
//
//  Created by artem on 17.01.2025.
//

import Foundation
import SwiftUI

import SwiftUI

struct ContentView9: View {
    
    @State private var isPresented = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.blue.opacity(0.8)
                .ignoresSafeArea()
            
            if isPresented {
                FullScreenModal(isPresented: $isPresented)
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: isPresented)
            }
        }
        .overlay(
            Button(action: { withAnimation { isPresented.toggle() } }) {
                Text("Открыть")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }, alignment: .center
        )
    }
}

struct FullScreenModal: View {
    
    @Binding var isPresented: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    
                    Button(action: { withAnimation { isPresented = false } }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                    }
                    .padding()
                }
                
                Spacer()
                
                Text("Это полноэкранный модальный вид")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.white)
            .gesture(DragGesture().onEnded({ value in
                if value.translation.height > 100 {
                    withAnimation { isPresented = false }
                }
            }))
        }
    }
}


#Preview {
    ContentView9()
}
