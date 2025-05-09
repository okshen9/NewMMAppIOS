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
						.font(MMFonts.subTitle)
                        .foregroundColor(Color.headerText)
                    if let subTitle{
                        Text(subTitle)
							.font(MMFonts.body)
                            .foregroundColor(Color.headerText)
                    }
                }
				.padding(8)
                .frame(width: geometry.size.width,
                       height: 46)
                .background(Color(hex: "F9F9F9"))
				.cornerRadius(16)
                
                
//            })
            
        }
        .shadow(color: .gray,
                radius: 4)
    }
}

#Preview {
    GroupButton(title: "Gjnjr Fdssdffsfsdfsdf", subTitle: "nil", action: {})
		.frame(width: 180)
}
