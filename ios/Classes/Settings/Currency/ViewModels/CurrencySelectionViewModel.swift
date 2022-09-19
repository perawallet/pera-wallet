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

//   CurrencySelectionViewModel.swift

import Foundation
import MacaroonUtils
import MacaroonUIKit

struct CurrencySelectionViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var description: TextProvider?

    init(
        currencyID: CurrencyID?
    ) {
        bindTitle()
        bindDescription(currencyID)
    }
}

extension CurrencySelectionViewModel {
    private mutating func bindTitle() {
        self.title =
        "settings-currency-title"
            .localized
            .bodyMedium()
    }

    private mutating func bindDescription(
        _ currencyID: CurrencyID?
    ) {
        let primaryCurrencyValue = currencyID?.localValue ?? CurrencyConstanst.unavailable
        let secondaryCurrencyValue = currencyID?.pairValue ?? CurrencyConstanst.unavailable

        let descriptionText = String(
            format: "settings-currency-description".localized,
            primaryCurrencyValue,
            secondaryCurrencyValue
        )
        let descriptionAttributedText = NSMutableAttributedString(
            attributedString: descriptionText.footnoteRegular()
        )

        let primaryCurrencyRange = (descriptionText as NSString).range(
            of: primaryCurrencyValue,
            options: []
        )
        descriptionAttributedText.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: Colors.Text.main.uiColor,
            range: primaryCurrencyRange
        )

        let secondaryCurrencyRange = (descriptionText as NSString).range(
            of: secondaryCurrencyValue,
            options: .backwards
        )
        descriptionAttributedText.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: Colors.Text.main.uiColor,
            range: secondaryCurrencyRange
        )

        self.description = descriptionAttributedText
    }
}
