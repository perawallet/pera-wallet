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

//   SwapConfirmPeraFeeInfoViewModel.swift

import MacaroonUIKit

struct SwapConfirmPeraFeeInfoViewModel: SwapInfoItemViewModel {
    private(set) var title: TextProvider?
    private(set) var icon: Image?
    private(set) var iconTintColor: Color?
    private(set) var detail: TextProvider?
    private(set) var action: Image?

    init(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        bindTitle()
        bindIcon()
        bindDetail(
            quote: quote,
            currencyFormatter: currencyFormatter
        )
        bindAction()
    }
}

extension SwapConfirmPeraFeeInfoViewModel {
    mutating func bindTitle() {
        title = "swap-confirm-pera-fee-title"
            .localized
            .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindIcon() {
        icon = nil
    }

    mutating func bindDetail(
        quote: SwapQuote,
        currencyFormatter: CurrencyFormatter
    ) {
        guard let peraFee = quote.peraFee?.toAlgos else { return }

        currencyFormatter.formattingContext = .standalone()
        currencyFormatter.currency = AlgoLocalCurrency()
        detail = currencyFormatter
            .format(peraFee)?
            .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    mutating func bindAction() {
        action = nil
    }
}
