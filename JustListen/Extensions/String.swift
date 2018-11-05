//
//  String.swift
//  JustListen
//
//  Created by Tien Tran on 11/1/18.
//  Copyright © 2018 Tien-Enterprise. All rights reserved.
//

import Foundation
extension String {
	func toSecureHTTPS() -> String {
		return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
	}
}
