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

//   AccountNotBackedUpWarningViewModel.swift

import Foundation
import MacaroonUIKit

struct AccountNotBackedUpWarningViewModel: Hashable {
    private(set) var title: TextProvider?
    private(set) var subtitle: TextProvider?
    private(set) var image: Image?
    private(set) var action: EditText?

    init() {
        title =
        "title-action-required"
            .localized
            .captionMedium()
        subtitle =
            "account-not-backed-up-warning-subtitle"
                .localized
                .bodyMedium(lineBreakMode: .byWordWrapping)
        image = "icon-circled-key"
        action = .attributedString(
            "account-not-backed-up-warning-action-title"
                .localized
                .footnoteMedium()
        )
    }

    static func == (
        lhs: AccountNotBackedUpWarningViewModel,
        rhs: AccountNotBackedUpWarningViewModel
    ) -> Bool {
        return lhs.title?.string == rhs.title?.string
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title?.string)
    }
}
