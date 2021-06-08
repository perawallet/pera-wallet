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
//  Int.swift

import Foundation

let algosInMicroAlgos = 1000000
let minimumFee: UInt64 = 1000
let minimumTransactionMicroAlgosLimit = 100000
let algosFraction = 6
let dataSizeForMaxTransaction: Int64 = 270

extension Int {
    var toAlgos: Double {
        return Double(self) / Double(algosInMicroAlgos)
    }
    
    func assetAmount(fromFraction decimal: Int) -> Double {
        if decimal == 0 {
            return Double(self)
        }
        return Double(self) / (pow(10, decimal) as NSDecimalNumber).doubleValue
    }
    
    func convertSecondsToHoursMinutesSeconds() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: TimeInterval(self))
    }
}

extension Int64 {
    var toAlgos: Double {
        return Double(self) / Double(algosInMicroAlgos)
    }
    
    func assetAmount(fromFraction decimal: Int) -> Double {
        if decimal == 0 {
            return Double(self)
        }
        return Double(self) / (pow(10, decimal) as NSDecimalNumber).doubleValue
    }
    
    func toFractionStringForLabel(fraction: Int) -> String? {
        return Formatter.separatorWith(fraction: fraction).string(from: NSNumber(value: self))
    }

    var isBelowZero: Bool {
        return self < 0
    }
}

extension UInt64 {
    var toAlgos: Double {
        return Double(self) / Double(algosInMicroAlgos)
    }
    
    func assetAmount(fromFraction decimal: Int) -> Double {
        if decimal == 0 {
            return Double(self)
        }
        return Double(self) / (pow(10, decimal) as NSDecimalNumber).doubleValue
    }
}
