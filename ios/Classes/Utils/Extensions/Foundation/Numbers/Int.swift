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
//  Int.swift

import Foundation

let algosInMicroAlgos = 1000000
let minimumFee: UInt64 = 1000
let totalNumIntConstantForMinimumAmount: UInt64 = 28500
let byteSliceConstantForMinimumAmount: UInt64 = 50000
let minimumTransactionMicroAlgosLimit: UInt64 = 100000
let algosFraction = 6
let dataSizeForMaxTransaction: UInt64 = 270

extension Int {
    func convertSecondsToHoursMinutesSeconds() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: TimeInterval(self))
    }
}

extension UInt64 {
    var toAlgos: Decimal {
        return Decimal(self) / Decimal(algosInMicroAlgos)
    }

    func assetAmount(fromFraction decimal: Int) -> Decimal {
        if decimal == 0 {
            return Decimal(self)
        }
        return Decimal(self) / pow(10, decimal)
    }

    var isBelowZero: Bool {
        return self < 0
    }
}
