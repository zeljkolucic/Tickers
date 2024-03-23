//
//  Symbol+image.swift
//  Tickers
//
//  Created by Zeljko Lucic on 23.3.24..
//

import SwiftUI
import UIKit

extension Symbol {
    private static var backgroundImages: [UIImage?] {
        [.blue, .green, .orange, .pink, .purple]
    }
    
    var image: Image {
        switch self {
        case .tBTCUSD:
            .bitcoin
        case .tETHUSD:
            .ethereum
        default:
            Image(uiImage: backgroundImage?.draw(name) ?? UIImage())
        }
    }
    
    private var backgroundImage: UIImage? {
        let index = Symbol.allCases.firstIndex(of: self) ?? 0
        return Self.backgroundImages[index % Self.backgroundImages.count]
    }
}
