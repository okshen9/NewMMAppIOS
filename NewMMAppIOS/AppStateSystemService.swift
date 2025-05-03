//
//  AppStateSystemService.swift
//  NewMMAppIOS
//
//  Created by artem on 03.05.2025.
//

import Foundation

final class AppStateSystemService: ObservableObject {
	static let shared = AppStateSystemService()
	private init() { }
	
	@Published var prodServ: AppSystemTarget = .test
	

}

enum AppSystemTarget: String, CaseIterable, Identifiable, Equatable {
	case prod = "Prod"
	case test = "Test"
	
	var id: String { self.rawValue }
}
