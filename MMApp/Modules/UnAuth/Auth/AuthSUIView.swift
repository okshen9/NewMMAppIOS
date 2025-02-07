//
//  AuthSUIView.swift
//  MMApp
//
//  Created by artem on 19.01.2025.
//

import Foundation
import WebKit
import SwiftUI

struct CollapsingView: View {
    @State private var expandedFraction: CGFloat = 0.0 // Состояние раскрытия треков (0.0 - свернуто, 1.0 - развернуто)
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                VStack {
                    HStack {
                        if expandedFraction > 0.1 { // Показывать заголовок только при частичном раскрытии
                            Text("Регистрация")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .opacity(expandedFraction)

                            Spacer()

                            Button(action: {
                                withAnimation(.spring()) {
                                    expandedFraction = 0
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.gray.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            .opacity(expandedFraction)
                            .padding()
                        }
                    }

                    WebView(url: URL(string: "https://www.example.com")!, isScrollEnabled: false)
                        .opacity(expandedFraction)
                        .frame(maxHeight: .infinity)

                    if expandedFraction < 0.9 {
                        Button(action: {
                            withAnimation(.spring()) {
                                expandedFraction = 1.0
                            }
                        }) {
                            Link("Sarunw", destination: URL(string: "https://sarunw.com")!)
                            Text("Развернуть")
                                .font(.headline)
                                .padding()
                                .background(Color.mainRed)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .opacity(1.0 - expandedFraction)
                    }
                }
                .frame(height: max(geometry.size.height * (0.5 + (expandedFraction * 0.5)), geometry.size.height * 0.5))
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(16)
                .shadow(radius: 10)
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset, body: { value, state, _ in
                            print(expandedFraction)
//                            if expandedFraction > 0 {
                                let dragAmount = value.translation.height / geometry.size.height
                                let newFraction = (expandedFraction - dragAmount).clamped(to: 0...1)
                                state = value.translation.height
                                expandedFraction = newFraction
//                            }
                        })
                        .onEnded { value in
                            let dragThreshold: CGFloat = 0.5 // Порог для определения направления
                            if expandedFraction > dragThreshold {
                                withAnimation(.spring()) {
                                    expandedFraction = 1.0
                                }
                            } else {
                                withAnimation(.spring()) {
                                    expandedFraction = 0.0
                                }
                            }
                        }
                )
                .contentShape(Rectangle())
                .allowsHitTesting(true)
                .clipped()
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            expandedFraction = 0.0 // Убедитесь, что установлена ​​правильная начальная высота.
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    let isScrollEnabled: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = isScrollEnabled
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.scrollView.isScrollEnabled = isScrollEnabled
    }
}

struct CollapsingView_Previews: PreviewProvider {
    static var previews: some View {
        CollapsingView()
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
