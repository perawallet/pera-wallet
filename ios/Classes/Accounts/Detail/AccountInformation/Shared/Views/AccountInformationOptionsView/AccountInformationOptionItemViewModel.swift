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

//   AccountInformationOptionItemViewModel.swift

import Foundation
import MacaroonUIKit

protocol AccountInformationOptionItemViewModel: ListItemButtonViewModel { }

extension AccountInformationOptionItemViewModel
where Self == RekeyToLedgerAccountInformationOptionItemViewModel {
    static var rekeyToLedger: Self { Self() }
}

extension AccountInformationOptionItemViewModel
where Self == RekeyToStandardAccountInformationOptionItemViewModel {
    static var rekeyToStandard: Self { Self() }
}

struct RekeyToLedgerAccountInformationOptionItemViewModel: AccountInformationOptionItemViewModel {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var accessory: Image?

    init() {
        title = .attributedString(
            "options-rekey-ledger"
                .localized
                .bodyRegular(lineBreakMode: .byTruncatingTail)
        )
        accessory = "icon-list-arrow".templateImage
    }
}

struct RekeyToStandardAccountInformationOptionItemViewModel: AccountInformationOptionItemViewModel {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var accessory: Image?

    init() {
        title = .attributedString(
            "options-rekey-standard"
                .localized
                .bodyRegular(lineBreakMode: .byTruncatingTail)
        )
        accessory = "icon-list-arrow".templateImage
    }
}
