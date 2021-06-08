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
//  QRText.swift

import Foundation

class QRText: Codable {
    let mode: QRMode
    let version = "1.0"
    let address: String?
    var mnemonic: String?
    var amount: Int64?
    var label: String?
    var asset: Int64?
    var note: String?
    var lockedNote: String?
    
    init(
        mode: QRMode,
        address: String?,
        mnemonic: String? = nil,
        amount: Int64? = nil,
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
        
        if try values.decodeIfPresent(String.self, forKey: .mnemonic) != nil {
            mode = .mnemonic
        } else if try values.decodeIfPresent(String.self, forKey: .asset) != nil,
            try values.decodeIfPresent(String.self, forKey: .amount) != nil {
            mode = .assetRequest
        } else if try values.decodeIfPresent(String.self, forKey: .amount) != nil {
            mode = .algosRequest
        } else {
            mode = .address
        }
        
        address = try values.decodeIfPresent(String.self, forKey: .address)
        label = try values.decodeIfPresent(String.self, forKey: .label)
        mnemonic = try values.decodeIfPresent(String.self, forKey: .mnemonic)
        
        if let amountText = try values.decodeIfPresent(String.self, forKey: .amount) {
            amount = Int64(amountText)
        }
        
        if let assetText = try values.decodeIfPresent(String.self, forKey: .asset) {
            asset = Int64(assetText)
        }

        note = try values.decodeIfPresent(String.self, forKey: .note)
        lockedNote = try values.decodeIfPresent(String.self, forKey: .lockedNote)
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
        }
    }
}

extension QRText {
    func qrText() -> String {
        let base = "algorand://"
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
