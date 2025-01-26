//
//  UIAplication+.swift
//  MMApp
//
//  Created by artem on 25.01.2025.
//

import Foundation
import UIKit

extension UIApplication {
    /// Переменная для получения самого верхнего ViewController'a в приложении
    var topmostViewController: UIViewController? {
        var topViewController = connectedScenes.compactMap {
            return ($0 as? UIWindowScene)?.windows
                .first(where: { $0.isKeyWindow })?
                .rootViewController
        }.first
        
        if let presented = topViewController?.presentedViewController {
            topViewController = presented
        } else if let navController = topViewController as? UINavigationController {
            topViewController = navController.topViewController
        } else if let tabBarController = topViewController as? UITabBarController {
            topViewController = tabBarController.selectedViewController
        }
        return topViewController
    }
}
