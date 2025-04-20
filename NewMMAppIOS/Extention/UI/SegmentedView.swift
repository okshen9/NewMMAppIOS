//
//  SegmentedView.swift
//  NewMMAppIOS
//
//  Created by artem on 19.04.2025.
//


import SwiftUI

struct SegmentedView: View {
    let segments: [String]
    let tintColor = Color.red
    let textColor: Color = .black
    @Binding var selected: Int
    @Namespace var name

    var body: some View {
        HStack(spacing: 0) {
            ForEach(segments, id: \.self) { segment in
                let currentSegnemtIndex = segments.firstIndex(where: {$0 == segment}) ?? 0
                VStack {

                    Text(segment)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(selected == currentSegnemtIndex ? textColor : Color(uiColor: .systemGray))
                    ZStack {
                        Capsule()
                            .fill(Color.clear)
                            .frame(height: 4)
                        if selected == currentSegnemtIndex {
                            Capsule()
                                .fill(tintColor)
                                .frame(height: 4)
                                .matchedGeometryEffect(id: "Tab", in: name)
                        }
                    }
                }
                .onTapGesture {
                    withAnimation {
                        selected = currentSegnemtIndex
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedIndex: Int = 0
    SegmentedView(segments: ["test1", "test2", "test3"], selected: $selectedIndex)
}
