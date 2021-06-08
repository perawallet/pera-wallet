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
//  Double.swift

import Foundation

extension Double {
    var toMicroAlgos: Int64 {
        return Int64(Double(algosInMicroAlgos) * self)
    }
    
    func toFraction(of fraction: Int) -> Int64 {
        if fraction == 0 {
            return Int64(self)
        }
        
        return Int64(self * (pow(10, fraction) as NSDecimalNumber).doubleValue)
    }
    
    var toDecimalStringForAlgosInput: String? {
        return Formatter.separatorForAlgosInput.string(from: NSNumber(value: self))
    }
    
    var toAlgosStringForLabel: String? {
        return Formatter.separatorForAlgosLabel.string(from: NSNumber(value: self))
    }

    var toRewardsStringForLabel: String? {
        return Formatter.separatorForRewardsLabel.string(from: NSNumber(value: self))
    }

    func toFractionStringForLabel(fraction: Int) -> String? {
        return Formatter.separatorWith(fraction: fraction).string(from: NSNumber(value: self))
    }

    func toExactFractionLabel(fraction: Int) -> String? {
        return Formatter.separatorForInputWith(fraction: fraction).string(from: NSNumber(value: self))
    }

    var toCurrencyStringForLabel: String? {
        return Formatter.currencyFormatter.string(from: NSNumber(value: self))
    }

    func toCurrencyStringForLabel(with symbol: String) -> String? {
        return Formatter.currencyFormatter(with: symbol).string(from: NSNumber(value: self))
    }

    var toPercentage: String? {
        return Formatter.percentageFormatter.string(from: NSNumber(value: self))
    }

    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
