// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgorandSecureBackupMnemonicViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgorandSecureBackupMnemonicViewModel: ViewModel {
    private(set) var title: String?
    private(set) var header: TextProvider?
    private(set) var peraLearn: TextLinkProvider?
    let isGenerationAvailable: Bool

    init(session: Session) {
        let isFirstBackup = !session.hasAlreadyCreatedBackupPrivateKey()
        isGenerationAvailable = !isFirstBackup
        bindTitle(isFirstBackup: isFirstBackup)
        bindHeader(isFirstBackup: isFirstBackup)
        bindPeraLearn(isFirstBackup: isFirstBackup)
    }

    private mutating func bindTitle(isFirstBackup: Bool) {
        if isFirstBackup {
            title = "algorand-secure-backup-mnemonics-title".localized
        } else {
            title = "algorand-secure-backup-mnemonics-second-backup-title".localized
        }
    }

    private mutating func bindHeader(isFirstBackup: Bool) {
        if isFirstBackup {
            header = "algorand-secure-backup-mnemonics-header".localized.bodyRegular()
        } else {
            header = "algorand-secure-backup-mnemonics-second-backup-header".localized.bodyRegular()
        }
    }

    private mutating func bindPeraLearn(isFirstBackup: Bool) {
        let text: String
        let highlightedText: String

        if isFirstBackup {
            text = "algorand-secure-backup-mnemonics-pera-learn".localized
            highlightedText = "alogrand-secure-backup-mnemonics-pera-learn-highlighted-text".localized
        } else {
            text = "algorand-secure-backup-mnemonics-second-backup-pera-learn".localized
            highlightedText = "alogrand-secure-backup-mnemonics-second-backup-pera-learn-highlighted-text".localized
        }

        var subtitleHighlightedTextAttributes = Typography.bodyMediumAttributes()
        subtitleHighlightedTextAttributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        peraLearn = TextLinkProvider(
            text: text.bodyRegular(),
            highlihtedText: highlightedText.bodyRegular(),
            highlightedTextAttributes: subtitleHighlightedTextAttributes
        )
    }
}

struct TextLinkProvider {
    let text: TextProvider
    let highlihtedText: TextProvider
    let highlightedTextAttributes: TextAttributeGroup
}
