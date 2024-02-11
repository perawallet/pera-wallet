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

//   SwapAPIErrorViewModel.swift

import MacaroonUIKit
import UIKit

struct SwapAPIErrorViewModel: ErrorScreenViewModel {
    private(set) var title: TextProvider?
    private(set) var detail: TextProvider?
    private(set) var primaryAction: TextProvider?
    private(set) var secondaryAction: TextProvider?

    init(
        quote: SwapQuote,
        error: SwapController.Error
    ) {
        bindTitle(quote)
        bindDetail(error)
        bindPrimaryAction()
        bindSecondaryAction()
    }
}

extension SwapAPIErrorViewModel {
    mutating func bindTitle(
        _ quote: SwapQuote
    ) {
        title = getTitle(from: quote)?
            .bodyLargeMedium(alignment: .center)
    }

    mutating func bindDetail(
        _ error: SwapController.Error
    ) {
        let message: String
        switch error {
        case .client(_, let apiError):
            message = apiError?.message ?? apiError.debugDescription
        case .server(_, let apiError):
            message = apiError?.message ?? apiError.debugDescription
        case .connection:
            message = "title-internet-connection".localized
        case .unexpected:
            message = "title-generic-api-error".localized
        }
        
        detail = message.bodyRegular(alignment: .center)
    }

    mutating func bindPrimaryAction() {
        primaryAction = "title-try-again"
            .localized
            .bodyMedium(alignment: .center)
    }

    mutating func bindSecondaryAction() {
        secondaryAction = "swap-error-go-home"
            .localized
            .bodyMedium(alignment: .center)
    }
}
