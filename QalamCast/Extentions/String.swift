//
//  String.swift
//  QalamCast
//
//  Created by Zakir Magdum on 5/31/18.
//  Copyright © 2018 Zakir Magdum. All rights reserved.
//

import Foundation
extension String {
    func toSecureHTTPS() -> String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

