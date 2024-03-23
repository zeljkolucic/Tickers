//
//  TickerView.swift
//  Tickers
//
//  Created by Zeljko Lucic on 22.3.24..
//

import SwiftUI

struct TickerView: View {
    private let ticker: Ticker
    
    init(ticker: Ticker) {
        self.ticker = ticker
    }
    
    var body: some View {
        HStack {
            ticker.symbol.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.imageWidth)
            Text(ticker.symbol.name)
            Spacer()
            VStack(alignment: .trailing) {
                Text(ticker.price)
                    .fontWeight(.bold)
                Text(ticker.dailyChangePercentage)
                    .foregroundStyle(ticker.dailyChangeRelative > 0 ? Color.primaryGreen : Color.primaryRed)
            }
        }
        .padding()
        .background(Color.secondaryBackground
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
            .shadow(color: .shadow, radius: Constants.shadowRadius, x: Constants.shadowOffset.width, y: Constants.shadowOffset.height)
        )
        .overlay {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(Color.border, style: StrokeStyle(lineWidth: Constants.lineWidth))
        } 
    }
    
    private struct Constants {
        static let imageWidth: CGFloat = 45
        static let cornerRadius: CGFloat = 6
        static let lineWidth: CGFloat = 1
        static let shadowRadius: CGFloat = 5
        static let shadowOffset: CGSize = CGSize(width: 0, height: 5)
    }
}

#Preview {
    TickerView(ticker: Ticker(symbol: .tBTCUSD, lastPrice: 64714, dailyChangeRelative: -0.04482591))
}
