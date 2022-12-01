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

//   SwapAssetInputValidator.swift

import MacaroonUIKit
import UIKit

struct SwapAssetInputValidator {

    /// <note>
    /// Check whether the input is a numeric value.
    /// Limit number of decimal separator to 1.
    /// Limit number of decimals with respect to the current asset.
    func validateInput(
        shouldChangeCharactersIn textField: TextField,
        with range: NSRange,
        replacementString string: String,
        for asset: Asset
    ) -> Bool {
        guard let currentText = textField.text,
              let currentTextRange = Range(range, in: currentText) else {
            return true
        }

        let newText = currentText.replacingCharacters(in: currentTextRange, with: string)
        let numberValueOfText = Formatter.decimalFormatter(maximumFractionDigits: asset.decimals).number(from: newText)
        let isNumeric = newText.isEmpty || numberValueOfText != nil

        if !isNumeric {
            return false
        }

        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        let numberOfDecimalSeparators = newText.components(separatedBy: decimalSeparator).count - 1

        if numberOfDecimalSeparators > 1 {
            return false
        }

        let numberOfDecimals: Int
        if let decimalSeparatorIndex = newText.firstIndex(of: Character(decimalSeparator)) {
            numberOfDecimals = newText.distance(
                from: decimalSeparatorIndex,
                to: newText.endIndex
            ) - 1
        } else {
            numberOfDecimals = 0
        }

        if string == "0" && numberOfDecimals == 0 && currentText.hasPrefix("0") {
            return false
        }

        if currentText == "0" && string != decimalSeparator && !string.isEmpty {
            return false
        }

        return numberOfDecimals <= asset.decimals
    }

    func isTheInputDecimalSeparator(
        _ input: String
    ) -> Bool {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."

        guard let lastCharacter = input.last else { return false }

        return String(lastCharacter) == decimalSeparator
    }
}
