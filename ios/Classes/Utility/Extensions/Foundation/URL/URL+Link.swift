// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  URL+Link.swift

import Foundation

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }
    
    func buildQRText() -> QRText? {
        guard let address = host else {
            return nil
        }
        
        guard let queryParameters = queryParameters else {
            if AlgorandSDK().isValidAddress(address) {
                return QRText(mode: .address, address: address)
            }
            return nil
        }
        
        if let amount = queryParameters[QRText.CodingKeys.amount.rawValue],
           let asset = queryParameters[QRText.CodingKeys.asset.rawValue] {
            return QRText(
                mode: .assetRequest,
                address: address,
                amount: Int64(amount),
                asset: Int64(asset),
                note: queryParameters[QRText.CodingKeys.note.rawValue],
                lockedNote: queryParameters[QRText.CodingKeys.lockedNote.rawValue]
            )
        }
        
        if let amount = queryParameters[QRText.CodingKeys.amount.rawValue] {
            return QRText(
                mode: .algosRequest,
                address: address,
                amount: Int64(amount),
                note: queryParameters[QRText.CodingKeys.note.rawValue],
                lockedNote: queryParameters[QRText.CodingKeys.lockedNote.rawValue]
            )
        }
        
        if let label = queryParameters[QRText.CodingKeys.label.rawValue] {
            return QRText(mode: .address, address: address, label: label)
        }
        
        return nil
    }
}
