//
//  UIImage+draw.swift
//  Tickers
//
//  Created by Zeljko Lucic on 23.3.24..
//

import UIKit
import SwiftUI

extension UIImage {
    func draw(
        _ text: String,
        color textColor: UIColor = .white,
        font: UIFont = .systemFont(ofSize: 8, weight: .regular)
    ) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
        draw(in: CGRect(origin: .zero, size: size))
        
        var textFontAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: style
        ]
        
        let textSize = text.size(withAttributes: textFontAttributes)
        let ratio = size.width / textSize.width * 0.7
        
        let textHeight = textSize.height
        let textYPosition = (size.height - textHeight * ratio) / 2
        
        let scaledFont = font.withSize(font.pointSize * ratio)
        textFontAttributes[.font] = scaledFont
        
        let textRect = CGRect(x: 0, y: textYPosition, width: size.width, height: size.height)
        text.draw(in: textRect.integral, withAttributes: textFontAttributes)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}

#Preview {
    HStack {
        Image(uiImage: UIImage(named: "blue")?.draw("FIL") ?? UIImage())
    }
    .previewLayout(.sizeThatFits)
    .padding()
}
