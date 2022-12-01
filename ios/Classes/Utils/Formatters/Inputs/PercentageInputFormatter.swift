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

//   PercentageInputFormatter.swift

import AnyFormatKit
import Foundation
import MacaroonForm

struct PercentageInputFormatter: MacaroonForm.NumberInputFormatter {
    private let base: SumTextInputFormatter

    init() {
        let formatter = NumberFormatter.percentageInputFormatter
        self.base = SumTextInputFormatter(numberFormatter: formatter)
    }

    func format(_ string: String?) -> String? {
        return base.format(string)
    }

    func format(_ number: NSNumber?) -> String? {
        return base.format(number?.stringValue)
    }

    func unformat(_ string: String?) -> String? {
        return base.unformat(string)
    }

    func unformat(_ string: String?) -> NSNumber? {
        return base.unformatNumber(string)
    }

    func format(
        _ input: String,
        changingCharactersIn range: NSRange,
        replacementString string: String
    ) -> TextInputFormattedOutput {
        let baseOutput = base.formatInput(
            currentText: input,
            range: range,
            replacementString: string
        )
        return (baseOutput.formattedText, baseOutput.caretBeginOffset)
    }
}
