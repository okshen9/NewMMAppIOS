//
//  AppStateSystemService.swift
//  NewMMAppIOS
//
//  Created by artem on 03.05.2025.
//

import Foundation

final class AppStateSystemService: ObservableObject {
	static let shared = AppStateSystemService()
	private init() {
		guard let nameStand = UserRepository.snapshot.nameStend ?? UserRepository.UserDefaultsStorege.nameStend.getData(String.self),
			  let stand = AppSystemTarget(rawValue: nameStand) else {
			#if DEBUG
			prodServ = .test
			#else
			prodServ = .prod
			#endif
			return
		}
		prodServ = stand
	}
	
	@Published var prodServ: AppSystemTarget {
		didSet {
			Task {
				await UserRepository.shared.setNameStend(prodServ.rawValue)
			}
		}
	}
}

enum AppSystemTarget: String, CaseIterable, Identifiable, Equatable {
	case prod = "Prod"
	case test = "Test"
	
	var id: String { self.rawValue }
}
