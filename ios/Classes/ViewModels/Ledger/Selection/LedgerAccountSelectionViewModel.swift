// Copyright 2019 Algorand, Inc.

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
//   LedgerAccountSelectionViewModel.swift

import Foundation

class LedgerAccountSelectionViewModel {
    private(set) var buttonText: String?
    private(set) var isEnabled: Bool = false

    init(isMultiSelect: Bool, selectedCount: Int) {
        setButtonText(from: isMultiSelect, and: selectedCount)
        setIsEnabled(from: selectedCount)
    }

    private func setButtonText(from isMultiSelect: Bool, and selectedCount: Int) {
        if isMultiSelect {
            buttonText = selectedCount <= 1
                ? "ledger-account-selection-verify".localized.localized
                : "ledger-account-selection-verify-plural".localized.localized
        } else {
            buttonText = "send-algos-select".localized
        }
    }

    private func setIsEnabled(from selectedCount: Int) {
        isEnabled = selectedCount > 0
    }
}
