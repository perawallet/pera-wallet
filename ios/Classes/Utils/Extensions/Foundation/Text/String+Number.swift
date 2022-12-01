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
//  String+Number.swift

import Foundation
import MacaroonUtils

extension String {
    var digits: String { return filter(("0"..."9").contains) }
    var decimal: Decimal { return Decimal(string: digits) ?? 0 }

    /// <note> Number formatters are not able to get the decimal values properly sometimes.
    var decimalAmount: Decimal? {
        let locale = Locale.current
        return Decimal(string: without(locale.groupingSeparator ?? ","), locale: locale)
    }

    var fractionCount: Int {
        guard let decimalString = self.decimalStrings() else {
            return 0
        }

        return decimalString.count - 1
    }

    func without<T: StringProtocol>(_ string: T) -> String {
        return replacingOccurrences(of: string, with: "")
    }

    func decimalStrings() -> String? {
        let separator = Locale.current.decimalSeparator?.first ?? "."
        let separated = self.split(separator: separator)

        if separated.count > 1 {
            return "\(separator)\(String(separated[1]))"
        } else if self.contains(separator) {
            return "\(separator)"
        }

        return nil
    }
}
