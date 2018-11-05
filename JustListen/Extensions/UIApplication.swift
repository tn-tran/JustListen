//
//  UIApplication.swift
//  JustListen
//
//  Created by Tien Tran on 11/3/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation
import UIKit
extension UIApplication {
	static func mainTabBarController() -> MainTabBarController {
		return UIApplication.shared.keyWindow?.rootViewController as! MainTabBarController
	}
}
