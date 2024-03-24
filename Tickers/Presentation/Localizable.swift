//
//  Localizable.swift
//  Tickers
//
//  Created by Zeljko Lucic on 22.3.24..
//

import Foundation

struct Localizable {
    struct NavigationBar {
        static let title = "NavigationBar.Title"
    }
    
    struct TabBar {
        static let title = "TabBar.Title"
    }
    
    struct Error {
        static let message = "Error.Message"
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
