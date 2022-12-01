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

    var toNumberStringWithSeparatorForLabel: String? {
        return Formatter.numberWithAutoSeparator.string(from: NSDecimalNumber(decimal: self))
    }

    func toNumberStringWithSeparatorForLabel(fraction: Int) -> String? {
        return Formatter.numberWithAutoSeparator(fraction: fraction).string(from: NSDecimalNumber(decimal: self))
    }

    func toFractionStringForLabel(fraction: Int) -> String? {
        return Formatter.separatorWith(fraction: fraction).string(from: NSDecimalNumber(decimal: self))
    }

    var toPercentage: String? {
        return Formatter.percentageFormatter.string(from: NSDecimalNumber(decimal: self))
    }

    func toPercentageWith(fractions value: Int) -> String? {
        return Formatter.percentageWith(fraction: value).string(from: NSDecimalNumber(decimal: self))
    }
}

extension Double {
    var toPercentage: String? {
        return Formatter.percentageFormatter.string(from: NSNumber(value: self))
    }

    func toPercentageWith(fractions value: Int) -> String? {
        return Formatter.percentageWith(fraction: value).string(from: NSNumber(value: self))
    }

    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
