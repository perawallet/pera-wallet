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

//   NumberRounder.swift

import Foundation

final class NumberRounder {
    var roundingMode: NSDecimalNumber.RoundingMode = .plain
    var supportedRoundingUnits: [NumberRoundingUnit] {
        get { getSupportedRoundingUnits() }
        set { setSupportedRoundingUnits(newValue) }
    }

    private var _supportedRoundingUnits: [NumberRoundingUnit] = []
}

extension NumberRounder {
    func round(
        _ decimalNumber: NSDecimalNumber
    ) -> NumberRoundingResult {
        for unit in supportedRoundingUnits {
            let resultByUnit = round(
                decimalNumber,
                by: unit
            )
            if let result = resultByUnit {
                return result
            }
        }

        return NumberRoundingResult(number: decimalNumber)
    }

    func round(
        _ decimalNumber: NSDecimalNumber,
        by unit: NumberRoundingUnit
    ) -> NumberRoundingResult? {
        let behaviour = NSDecimalNumberHandler(
            roundingMode: roundingMode,
            scale: unit.scale,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        let roundedDecimalNumber = decimalNumber.multiplying(
            byPowerOf10: unit.powerOf10,
            withBehavior: behaviour
        )

        if roundedDecimalNumber.compare(NSDecimalNumber.one) != .orderedAscending {
            let abbrev = unit.abbreviation
            return NumberRoundingResult(number: roundedDecimalNumber, abbreviation: abbrev)
        }

        return nil
    }
}

extension NumberRounder {
    private func getSupportedRoundingUnits() -> [NumberRoundingUnit] {
        return _supportedRoundingUnits
    }

    private func setSupportedRoundingUnits(
        _ newValue: [NumberRoundingUnit]
    ) {
        /// <note>
        /// In order to improve the performance to find the correct rounding unit.
        _supportedRoundingUnits = newValue.sorted(
            by: \.powerOf10,
            using: <
        )
    }
}

protocol NumberRoundingUnit {
    /// The value to be used in a multiplication operation.
    /// It should be negative if the rounding requires a division operation.
    var powerOf10: Int16 { get }
    /// The number of digits after the decimal point.
    var scale: Int16 { get }
    var abbreviation: NumberAbbreviation { get }
}

struct ThousandNumberRoundingUnit: NumberRoundingUnit {
    let powerOf10: Int16 = -3
    let scale: Int16 = 2
    let abbreviation: NumberAbbreviation = .init(
        short: "number-abbreviation-thousand".localized,
        long: ""
    )
}

struct MillionNumberRoundingUnit: NumberRoundingUnit {
    let powerOf10: Int16 = -6
    let scale: Int16 = 2
    let abbreviation: NumberAbbreviation = .init(
        short: "number-abbreviation-million".localized,
        long: ""
    )
}

struct BillionNumberRoundingUnit: NumberRoundingUnit {
    let powerOf10: Int16 = -9
    let scale: Int16 = 2
    let abbreviation: NumberAbbreviation = .init(
        short: "number-abbreviation-billion".localized,
        long: ""
    )
}

struct TrillionNumberRoundingUnit: NumberRoundingUnit {
    let powerOf10: Int16 = -12
    let scale: Int16 = 2
    let abbreviation: NumberAbbreviation = .init(
        short: "number-abbreviation-trillion".localized,
        long: ""
    )
}

struct QuadrillionNumberRoundingUnit: NumberRoundingUnit {
    let powerOf10: Int16 = -15
    let scale: Int16 = 2
    let abbreviation: NumberAbbreviation = .init(
        short: "number-abbreviation-quadrillion".localized,
        long: ""
    )
}

struct QuintillionNumberRoundingUnit: NumberRoundingUnit {
    let powerOf10: Int16 = -18
    let scale: Int16 = 2
    let abbreviation: NumberAbbreviation = .init(
        short: "number-abbreviation-quintillion".localized,
        long: ""
    )
}

struct NumberRoundingResult {
    let number: NSDecimalNumber
    let abbreviation: NumberAbbreviation?

    init(
        number: NSDecimalNumber,
        abbreviation: NumberAbbreviation? = nil
    ) {
        self.number = number
        self.abbreviation = abbreviation
    }
}

struct NumberAbbreviation {
    let short: String
    let long: String
}
