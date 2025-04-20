//
//  FeedMenu.swift
//  NewMMAppIOS
//
//  Created by artem on 13.04.2025.
//

import SwiftUI

//struct FeedMenu: View {
//    @State var selectedType: [EventType: Bool]
//    var body: some View {
//        Menu {
//
//            VStack {
////                let sortedType = selectedType.sorted(by: {$0.key.rawValue < $1.key.rawValue})
//                ForEach($selectedType.sorted(by: {$0.key.rawValue < $1.key.rawValue}), id: \.wrappedValue.key.rawValue) { key, value in
//                    HStack {
//                        Text(key.name)
//                        ChekMarkView(value)
//                    }
//                }
//                Button(action: {
//
//                }, label: {
//                    Text("Сохранить")
//                })
//            }
//        } label: {
//            Image(systemName: "line.3.horizontal.decrease.circle.fill")
//                .foregroundStyle(Color.mainRed)
//        }
//    }
//}
//
//#Preview {
//    FeedMenu()
//}
