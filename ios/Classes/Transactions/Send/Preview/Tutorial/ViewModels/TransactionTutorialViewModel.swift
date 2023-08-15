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
//   TransactionTutorialViewModel.swift

import UIKit
import MacaroonUIKit

final class TransactionTutorialViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var subtitle: TextProvider?
    private(set) var firstInstruction: InstructionItemViewModel?
    private(set) var secondInstruction: InstructionItemViewModel?
    private(set) var tapToMoreText: TextProvider?

    init(isInitialDisplay: Bool) {
        bindTitle()
        bindSubtitle(from: isInitialDisplay)
        bindFirstInstruction()
        bindSecondInstruction()
        bindTapToMoreText()
    }
}

extension TransactionTutorialViewModel {
    private func bindTitle() {
        title =
            "transaction-tutorial-title"
                .localized
                .bodyLargeMedium(
                    alignment: .center
                )
    }
    
    private func bindSubtitle(from isInitialDisplay: Bool) {
        let subtitle: String
        if isInitialDisplay {
            subtitle = "transaction-tutorial-subtitle".localized
        } else {
            subtitle = "transaction-tutorial-subtitle-other".localized
        }
        
        self.subtitle =
            subtitle
                .bodyRegular(
                    alignment: .center
                )
    }
    
    private func bindFirstInstruction() {
        firstInstruction = TransactionSmallTestTransactionInstructionItemViewModel(order: 1)
    }
    
    private func bindSecondInstruction() {
        secondInstruction = TransactionCorrectAddressInstructionItemViewModel(order: 2)
    }
    
    private func bindTapToMoreText() {
        let highlightedText = "transaction-tutorial-tap-to-more-highlighted".localized
        var highlightedTextAttributes = Typography.footnoteMediumAttributes()
        highlightedTextAttributes.insert(.textColor(Colors.Link.primary))

        tapToMoreText =
            "transaction-tutorial-tap-to-more"
                .localized
                .footnoteRegular()
                .addAttributes(
                    to: highlightedText,
                    newAttributes: highlightedTextAttributes
                )
    }
}
