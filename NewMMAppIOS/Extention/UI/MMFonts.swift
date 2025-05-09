//
//  MMFonts.swift
//  NewMMAppIOS
//
//  Created by artem on 09.05.2025.
//

import Foundation
import SwiftUI

enum MMFonts {
	static var title: Font {
		.custom("SangBleuSunrise-Bold-WebXL", size: 22)
	}
	
	static var subTitle: Font {
		.custom("SangBleuSunrise-Medium-WebXL", size: 18)
	}
	
	static var body: Font {
		.custom("SangBleuSunrise-Regular-WebXL", size: 16)
	}
	
	static var caption: Font {
		.custom("SangBleuSunrise-Livre-WebXL", size: 14)
	}
	
	static var subCaption: Font {
		.custom("SangBleuSunrise-Light-WebXL", size: 12)
	}
}
