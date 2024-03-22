//
//  Symbol.swift
//  Tickers
//
//  Created by Zeljko Lucic on 21.3.24..
//

import Foundation

public enum Symbol: String, CaseIterable, Decodable {
    case tBTCUSD
    case tETHUSD
    case tCHSBUSD = "tCHSB:USD"
    case tLTCUSD
    case tXRPUSD
    case tDSHUSD
    case tRRTUSD
    case tEOSUSD
    case tSANUSD
    case tDATUSD
    case tSNTUSD
    case tDOGEUSD = "tDOGE:USD"
    case tLUNAUSD = "tLUNA:USD"
    case tMATICUSD = "tMATIC:USD"
    case tNEXOUSD = "tNEXO:USD"
    case tOCEANUSD = "tOCEAN:USD"
    case tBESTUSD = "tBEST:USD"
    case tAAVEUSD = "tAAVE:USD"
    case tPLUUSD
    case tFILUSD
    
    public var name: String {
        let suffixLength = currencyCode.count
        var name = rawValue.dropFirst().dropLast(suffixLength)
        if name.hasSuffix(":") {
            name.removeLast()
        }
        return String(name)
    }
    
    var currencyCode: String {
        "USD"
    }
}
