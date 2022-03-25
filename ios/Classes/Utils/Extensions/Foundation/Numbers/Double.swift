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
//  Double.swift

import Foundation

extension Decimal {
    typealias Abbreviation = (threshold:Double, divisor:Double, suffix:String)
    
    var uint64Value: UInt64 {
        return NSDecimalNumber(decimal: self).uint64Value
    }

    var toMicroAlgos: UInt64 {
        return (Decimal(algosInMicroAlgos) * self).uint64Value
    }

    func toFraction(of fraction: Int) -> UInt64 {
        if fraction == 0 {
            return self.uint64Value
        }

        return (self * pow(10, fraction)).uint64Value
    }

    var toDecimalStringForAlgosInput: String? {
        return Formatter.separatorForAlgosInput.string(from: NSDecimalNumber(decimal: self))
    }

    var toAlgosStringForLabel: String? {
        return Formatter.separatorForAlgosLabel.string(from: NSDecimalNumber(decimal: self))
    }
    
    var toFullAlgosStringForLabel: String? {
        let number = NSDecimalNumber(decimal: self)
        let abbreviation = getAbbreviation(for: number)
        
        let finalNumber = NSDecimalNumber(value: number.doubleValue / abbreviation.divisor)
        
        return Formatter.fullAlgosLabel(with: abbreviation.suffix).string(from: finalNumber)
    }

    var toNumberStringWithSeparatorForLabel: String? {
        return Formatter.numberWithAutoSeparator.string(from: NSDecimalNumber(decimal: self))
    }

    func toNumberStringWithSeparatorForLabel(fraction: Int) -> String? {
        return Formatter.numberWithAutoSeparator(fraction: fraction).string(from: NSDecimalNumber(decimal: self))
    }

    var toRewardsStringForLabel: String? {
        return Formatter.separatorForRewardsLabel.string(from: NSDecimalNumber(decimal: self))
    }

    func toFractionStringForLabel(fraction: Int) -> String? {
        return Formatter.separatorWith(fraction: fraction).string(from: NSDecimalNumber(decimal: self))
    }

    func toExactFractionLabel(fraction: Int) -> String? {
        return Formatter.separatorForInputWith(fraction: fraction).string(from: NSDecimalNumber(decimal: self))
    }

    var toCurrencyStringForLabel: String? {
        return Formatter.currencyFormatter.string(from: NSDecimalNumber(decimal: self))
    }

    func toCurrencyStringForLabel(with symbol: String?) -> String? {
        return Formatter.currencyFormatter(with: symbol).string(from: NSDecimalNumber(decimal: self))
    }
    
    func abbreviatedFractionStringForLabel(fraction: Int) -> String? {
        let number = NSDecimalNumber(decimal: self)
        let abbreviation = getAbbreviation(for: number)
        
        let finalNumber = NSDecimalNumber(value: number.doubleValue / abbreviation.divisor)
        
        return Formatter.separatorWith(fraction: fraction, suffix: abbreviation.suffix).string(from: finalNumber)
    }
    
    func abbreviatedCurrencyStringForLabel(with symbol: String?) -> String? {
        let number = NSDecimalNumber(decimal: self)
        let abbreviation = getAbbreviation(for: number)
        
        let finalNumber = NSDecimalNumber(value: number.doubleValue / abbreviation.divisor)
        
        return Formatter.currencyFormatter(with: symbol, suffix: abbreviation.suffix).string(from: finalNumber)
    }

    var toPercentage: String? {
        return Formatter.percentageFormatter.string(from: NSDecimalNumber(decimal: self))
    }
    
    private func getAbbreviation(for number: NSDecimalNumber) -> Abbreviation {
        let abbreviations: [Abbreviation] = [
            (0, 1, ""),
            (1_000, 1_000, "K"),
            (1_000_000.0, 1_000_000.0, "M"),
            (1_000_000_000.0, 1_000_000_000.0, "B"),
            (1_000_000_000_000.0, 1_000_000_000_000.0, "T")
        ]

        let startValue = number
        
        var abbreviationIndex = 0
        
        while abbreviationIndex < abbreviations.count {
            let abbreviation = abbreviations[abbreviationIndex]
            
            if startValue.doubleValue < abbreviation.threshold {
                break
            }
            
            abbreviationIndex = abbreviationIndex.advanced(by: 1)
        }
        
        abbreviationIndex = max(0, abbreviationIndex.advanced(by: -1))
        
        return abbreviations[abbreviationIndex]
    }
}

extension Double {
    var toMicroAlgos: UInt64 {
        return UInt64(Double(algosInMicroAlgos) * self)
    }
    
    func toFraction(of fraction: Int) -> UInt64 {
        if fraction == 0 {
            return UInt64(self)
        }
        
        return UInt64(self * (pow(10, fraction) as NSDecimalNumber).doubleValue)
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

    func toCurrencyStringForLabel(with symbol: String?) -> String? {
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
