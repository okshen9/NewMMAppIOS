//
//  GoupeView.swift
//  MMApp
//
//  Created by artem on 22.02.2025.
//

import SwiftUI

struct GroupButton: View {
    let title: String
    let subTitle: String?
    let action: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            
//            Button (action: {
//                //            action()
//                print("dfdf")
//            }, label: {
                VStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color.headerText)
                    if let subTitle{
                        Text(subTitle)
                            .font(.subheadline)
                            .foregroundColor(Color.headerText)
                    }
                }
                .frame(width: geometry.size.width,
                       height: 56)
                .background(Color.gray)
                .cornerRadius(16)
                
//            })
            
        }
        .shadow(radius: 8)
    }
}

#Preview {
    GroupButton(title: "dfdf", subTitle: nil, action: {})
}
