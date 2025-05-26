//
//  MMFonts.swift
//  NewMMAppIOS
//
//  Created by artem on 09.05.2025.
//

import Foundation
import SwiftUI

enum MMFonts {
	static var titleULTRA: Font {
		.custom("SangBleu Sunrise", size: 22)
	}
	
	static var title: Font {
//		.custom("SangBleu Sunrise-Bold-WebXL", size: 22)
		Font.custom("SangBleu", size: 22).weight(.bold)
	}
	
	static var subTitle: Font {
		.custom("SangBleu Sunrise", size: 18)
	}
	
	static var body: Font {
		.custom("SangBleu Sunrise", size: 16)
	}
	
	static var caption: Font {
		.custom("SangBleu Sunrise", size: 14)
	}
	
	static var subCaption: Font {
		.custom("SangBleu Sunrise", size: 12)
		.bold()
	}
	
	static func custom(_ size: CGFloat, _ width: WidthFont = .regular) -> Font {
		var fontName: String
		switch width {
		case .bold: fontName = "SangBleu Sunrise"
		case .medium: fontName = "SangBleu Sunrise"
		case .regular: fontName = "SangBleu Sunrise"
		case .light: fontName = "SangBleu Sunrise"
		}
		return .custom(fontName, size: size)
	}
	
	enum WidthFont {
		case bold
		case medium
		case regular
		case light
		
	}
}


//enum MMFonts {
//	static var title: Font {
//		.custom("SangBleu Sunrise Bold", size: 22)
//	}
//	
//	static var subTitle: Font {
//		.custom("SangBleu Sunrise Medium", size: 18)
//	}
//	
//	static var body: Font {
//		.custom("SangBleu Sunrise Regular", size: 16)
//	}
//	
//	static var caption: Font {
//		.custom("SangBleu Sunrise Regular", size: 14)
//	}
//	
//	static var subCaption: Font {
//		.custom("SangBleu Sunrise Light", size: 12)
//	}
//}
