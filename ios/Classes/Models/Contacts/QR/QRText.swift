// Copyright 2022 Pera Wallet, LDA

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
//  QRText.swift

import Foundation

final class QRText: Codable {
    let mode: QRMode
    let version = "1.0"
    let address: String?
    var mnemonic: String?
    var amount: UInt64?
    var label: String?
    var asset: Int64?
    var note: String?
    var lockedNote: String?
    
    init(
        mode: QRMode,
        address: String?,
        mnemonic: String? = nil,
        amount: UInt64? = nil,
        label: String? = nil,
        asset: Int64? = nil,
        note: String? = nil,
        lockedNote: String? = nil
    ) {
        self.mode = mode
        self.address = address
        self.mnemonic = mnemonic
        self.amount = amount
        self.label = label
        self.asset = asset
        self.note = note
        self.lockedNote = lockedNote
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        address = try values.decodeIfPresent(String.self, forKey: .address)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        mnemonic = try values.decodeIfPresent(String.self, forKey: .mnemonic)
        
        if let amountText = try values.decodeIfPresent(String.self, forKey: .amount) {
            amount = UInt64(amountText)
        }
        
        if let assetText = try values.decodeIfPresent(String.self, forKey: .asset) {
            asset = Int64(assetText)
        }

        note = try values.decodeIfPresent(String.self, forKey: .note)
        lockedNote = try values.decodeIfPresent(String.self, forKey: .lockedNote)

        if mnemonic != nil {
            mode = .mnemonic
        } else if asset != nil,
                  amount != nil {
            if amount == 0 && address == nil {
                mode = .optInRequest
            } else {
                mode = .assetRequest
            }
        } else if try values.decodeIfPresent(String.self, forKey: .amount) != nil {
            mode = .algosRequest
        } else {
            mode = .address
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(version, forKey: .version)
        
        switch mode {
        case .mnemonic:
            try container.encode(mnemonic, forKey: .mnemonic)
        case .address:
            if let address = address {
                try container.encode(address, forKey: .address)
            }
            if let label = label {
                try container.encode(label, forKey: .label)
            }
        case .algosRequest:
            if let address = address {
                try container.encode(address, forKey: .address)
            }
            if let amount = amount {
                try container.encode(amount, forKey: .amount)
            }
            if let note = note {
                try container.encode(note, forKey: .note)
            }
            if let lockedNote = lockedNote {
                try container.encode(lockedNote, forKey: .lockedNote)
            }
        case .assetRequest:
            if let address = address {
                try container.encode(address, forKey: .address)
            }
            if let amount = amount {
                try container.encode(amount, forKey: .amount)
            }
            if let asset = asset {
                try container.encode(asset, forKey: .asset)
            }
            if let note = note {
                try container.encode(note, forKey: .note)
            }
            if let lockedNote = lockedNote {
                try container.encode(lockedNote, forKey: .lockedNote)
            }
        case .optInRequest:
            if let amount = amount {
                try container.encode(amount, forKey: .amount)
            }
            if let asset = asset {
                try container.encode(asset, forKey: .asset)
            }
        }
    }

    class func build(for address: String?, with queryParameters: [String: String]?) -> Self? {
        guard let queryParameters = queryParameters else {
            if let address = address {
                return Self(mode: .address, address: address)
            }

            return nil
        }

        if let amount = queryParameters[QRText.CodingKeys.amount.rawValue],
           let asset = queryParameters[QRText.CodingKeys.asset.rawValue] {

            if let address = address {
                return Self(
                    mode: .assetRequest,
                    address: address,
                    amount: UInt64(amount),
                    asset: Int64(asset),
                    note: queryParameters[QRText.CodingKeys.note.rawValue],
                    lockedNote: queryParameters[QRText.CodingKeys.lockedNote.rawValue]
                )
            }

            if amount == "0" {
                return Self(
                    mode: .optInRequest,
                    address: nil,
                    amount: UInt64(amount),
                    asset: Int64(asset),
                    note: queryParameters[QRText.CodingKeys.note.rawValue],
                    lockedNote: queryParameters[QRText.CodingKeys.lockedNote.rawValue]
                )
            }

            return nil
        }

        guard let address = address else {
            return nil
        }

        if let amount = queryParameters[QRText.CodingKeys.amount.rawValue] {
            return Self(
                mode: .algosRequest,
                address: address,
                amount: UInt64(amount),
                note: queryParameters[QRText.CodingKeys.note.rawValue],
                lockedNote: queryParameters[QRText.CodingKeys.lockedNote.rawValue]
            )
        }

        if let label = queryParameters[QRText.CodingKeys.label.rawValue] {
            return Self(mode: .address, address: address, label: label)
        }

        return nil
    }
}

extension QRText {
    func qrText() -> String {
        /// <todo>
        /// This should be converted to a builder/generator, not implemented in the model itself.
        let deeplinkConfig = ALGAppTarget.current.deeplinkConfig.qr
        let base = "\(deeplinkConfig.preferredScheme)://"
        switch mode {
        case .mnemonic:
            if let mnemonic = mnemonic {
                return "\(mnemonic)"
            }
        case .address:
            guard let address = address else {
                return base
            }
            if let label = label {
                return "\(base)\(address)?\(CodingKeys.label.rawValue)=\(label)"
            }
            return "\(address)"
        case .algosRequest:
            guard let address = address else {
                return base
            }
            var query = ""
            if let amount = amount {
                query += "?\(CodingKeys.amount.rawValue)=\(amount)"
            }

            if let note = note {
                query += "&\(CodingKeys.note.rawValue)=\(note)"
            }

            if let lockedNote = lockedNote {
                query += "&\(CodingKeys.lockedNote.rawValue)=\(lockedNote)"
            }

            return "\(base)\(address)\(query)"
        case .assetRequest:
            guard let address = address else {
                return base
            }
            var query = ""
            if let amount = amount {
                query += "?\(CodingKeys.amount.rawValue)=\(amount)"
            }
            
            if let asset = asset, !query.isEmpty {
                query += "&\(CodingKeys.asset.rawValue)=\(asset)"
            }

            if let note = note {
                query += "&\(CodingKeys.note.rawValue)=\(note)"
            }

            if let lockedNote = lockedNote {
                query += "&\(CodingKeys.lockedNote.rawValue)=\(lockedNote)"
            }

            return "\(base)\(address)\(query)"
        case .optInRequest:
            var query = ""

            if let asset = asset,
               !query.isEmpty {
                query += "?\(CodingKeys.amount.rawValue)=0"
                query += "&\(CodingKeys.asset.rawValue)=\(asset)"
            }

            return "\(base)\(query)"
        }
        return ""
    }
}

extension QRText {
    enum CodingKeys: String, CodingKey {
        case mode = "mode"
        case version = "version"
        case address = "address"
        case mnemonic = "mnemonic"
        case amount = "amount"
        case label = "label"
        case asset = "asset"
        case note = "note"
        case lockedNote = "xnote"
    }
}
