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

//   AssetActionConfirmationLoadingViewModel.swift

import Foundation
import MacaroonUIKit

struct AssetActionConfirmationLoadingViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var body: TextProvider?
    private(set) var bodyAccessory: ImageProvider?
    private(set) var primaryAction: String?
    private(set) var secondaryAction: String?

    init(draft: AssetAlertDraft) {
        bindTitle(draft: draft)
        bindBody(draft: draft)
        bindBodyAccessory(draft: draft)
        bindPrimaryAction(draft: draft)
        bindSecondaryAction(draft: draft)
    }
}

extension AssetActionConfirmationLoadingViewModel {
    mutating func bindTitle(draft: AssetAlertDraft) {
        title = draft.title?.bodyMedium(alignment: .center)
    }

    mutating func bindBody(draft: AssetAlertDraft) {
        body = draft.detail?.footnoteMedium()
    }

    mutating func bindBodyAccessory(draft: AssetAlertDraft) {
        bodyAccessory = "icon-red-warning".uiImage
    }

    mutating func bindPrimaryAction(draft: AssetAlertDraft) {
        primaryAction = draft.actionTitle
    }

    mutating func bindSecondaryAction(draft: AssetAlertDraft) {
        secondaryAction = draft.cancelTitle
    }
}
