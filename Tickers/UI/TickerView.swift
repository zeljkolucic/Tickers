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
            Image(systemName: "globe")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Constants.imageWidth)
            Text(ticker.name)
                .fontWeight(.bold)
            Spacer()
            VStack(alignment: .trailing) {
                Text(ticker.price)
                    .fontWeight(.bold)
                Text(ticker.dailyChangePercentage)
                    .foregroundStyle(ticker.dailyChangeRelative > 0 ? .green : .red)
            }
        }
        .padding()
        .background(.white)
        .overlay {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(.gray, style: StrokeStyle(lineWidth: Constants.lineWidth))
        }
        .shadow(color: .init(white: 0.8), radius: Constants.shadowRadius, x: Constants.shadowOffset.width, y: Constants.shadowOffset.height)
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
    TickerView(ticker: Ticker(name: "BTC", lastPrice: 64714, dailyChangeRelative: -0.04482591))
}
