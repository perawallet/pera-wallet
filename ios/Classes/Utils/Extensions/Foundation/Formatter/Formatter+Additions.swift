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

extension Formatter {
    static let separatorForAlgosInput: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 6
        formatter.maximumFractionDigits = 6
        return formatter
    }()
    
    static let separatorForAlgosLabel: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = "\u{00A6}"
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 6
        return formatter
    }()

    static let separatorForRewardsLabel: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 8
        formatter.maximumFractionDigits = 8
        return formatter
    }()

    static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static func separatorForInputWith(fraction value: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = value
        formatter.maximumFractionDigits = value
        return formatter
    }
    
    static func separatorWith(fraction value: Int, suffix: String? = nil) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = value == 0 ? 0 : 2
        formatter.maximumFractionDigits = value
        formatter.negativeSuffix = suffix
        formatter.positiveSuffix = suffix
        return formatter
    }
    
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static func currencyFormatter(with symbol: String?, suffix: String? = nil) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = symbol ?? ""
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.negativeSuffix = suffix
        formatter.positiveSuffix = suffix
        return formatter
    }

    static let numberWithAutoSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        return formatter
    }()

    static func numberWithAutoSeparator(fraction value: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = ""
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = value
        return formatter
    }
    
    static func fullAlgosLabel(with suffix: String) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.preferred()
        formatter.currencySymbol = "\u{00A6}"
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.positiveSuffix = suffix
        formatter.negativeSuffix = suffix
        return formatter
    }
}
