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
//   SelectAccountHeaderViewModel.swift


import Foundation
import UIKit
import MacaroonUIKit

protocol TitleHeaderViewModel: PairedViewModel {
    var title: String? { get }
}

final class SelectAccountHeaderViewModel: TitleHeaderViewModel, Hashable {
    private let mode: SelectAccountHeaderMode

    private(set) var title: String?

    init(_ model: SelectAccountHeaderMode) {
        self.mode = model
        bindTitle(model)
    }

    private func bindTitle(_ mode: SelectAccountHeaderMode) {
        switch mode {
        case .matchedAccounts:
            self.title = "account-select-header-matched-accounts-title".localized
        case .accounts:
            self.title = "account-select-header-accounts-title".localized
        case .contacts:
            self.title = "account-select-header-contacts-title".localized
        case .search:
            self.title = "title-account".localized
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    static func == (lhs: SelectAccountHeaderViewModel, rhs: SelectAccountHeaderViewModel) -> Bool {
        lhs.mode == rhs.mode &&
        lhs.title == rhs.title
    }
}

enum SelectAccountHeaderMode {
    case matchedAccounts
    case accounts
    case contacts
    case search
}
