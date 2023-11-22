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
//  Formatter+Additions.swift

import Foundation
import MacaroonUtils

extension Formatter {
    static let algoCurrencySymbol = "\u{00A6}"
    
    static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let percentageInputFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.notANumberSymbol = ""
        return formatter
    }()

    static func percentageWith(fraction value: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = value
        return formatter
    }
    
    static func separatorWith(fraction value: Int, suffix: String? = nil) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = value == 0 ? 0 : 2
        if let suffix = suffix, !suffix.isEmptyOrBlank {
            formatter.roundingMode = .down
            formatter.maximumFractionDigits = 2
        } else {
            formatter.maximumFractionDigits = value
        }
        formatter.negativeSuffix = suffix
        formatter.positiveSuffix = suffix
        return formatter
    }
    
    static let numberWithAutoSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        return formatter
    }()

    static func numberWithAutoSeparator(fraction value: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = value
        return formatter
    }

    static func decimalFormatter(
        maximumFractionDigits: Int = 0,
        groupingSeparator: String? = nil
    ) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .current
        if let groupingSeparator {
            formatter.groupingSeparator = groupingSeparator
        }
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter
    }
}
