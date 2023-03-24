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
//  AccountTypeViewModel.swift

import UIKit
import MacaroonUIKit
import Foundation

struct AccountTypeViewModel: PairedViewModel {
    private(set) var image: UIImage?
    private(set) var title: String?
    private(set) var detail: String?
    private(set) var badge: String?
    
    init(_ model: AccountSetupMode) {
        bindImage(model)
        bindTitle(model)
        bindBadge(model)
        bindDetail(model)
    }
}

extension AccountTypeViewModel {
    private mutating func bindImage(_ mode: AccountSetupMode) {
        switch mode {
        case let .add(type):
            switch type {
            case .watch:
                image = img("icon-add-watch-account")
            case .none, .create:
                image = img("icon-add-account")
            }
        case let .recover(type):
            switch type {
            case .none, .passphrase:
                image = img("icon-recover-passphrase")
            case .ledger:
                image = img("icon-pair-ledger-account")
            case .importFromWeb:
                image = img("icon-import-from-web")
            }
        case .rekey,
             .none:
            break
        }
    }
    
    private mutating func bindTitle(_ mode: AccountSetupMode) {
        switch mode {
        case let .add(type):
            switch type {
            case .create:
                title = "account-type-selection-create".localized
            case .watch:
                title = "account-type-selection-watch".localized
            case .none:
                title = "account-type-selection-add".localized
            }
        case let .recover(type):
            switch type {
            case .passphrase:
                title = "account-type-selection-passphrase".localized
            case .ledger:
                title = "account-type-selection-ledger".localized
            case .importFromWeb:
                title = "account-type-selection-import-web".localized
            case .none:
                title = "account-type-selection-recover".localized
            }
        case .rekey,
             .none:
            break
        }
    }

    private mutating func bindBadge(_ mode: AccountSetupMode) {
        switch mode {
        case let .recover(type):
            switch type {
            case .importFromWeb:
                badge = "title-new-uppercased".localized
            default:
                break
            }
        default:
            break
        }
    }

    private mutating func bindDetail(_ mode: AccountSetupMode) {
        switch mode {
        case let .add(type):
            switch type {
            case .create:
                detail = "account-type-selection-add-detail".localized
            case .watch:
                detail = "account-type-selection-watch-detail".localized
            case .none:
                detail = "account-type-selection-create-detail".localized
            }
        case let .recover(type):
            switch type {
            case .passphrase:
                detail = "account-type-selection-passphrase-detail".localized
            case .ledger:
                detail = "account-type-selection-ledger-detail".localized
            case .importFromWeb:
                detail = "account-type-selection-import-web-detail".localized
            case .none:
                detail = "account-type-selection-recover-detail".localized
            }
        case .rekey,
             .none:
            break
        }
    }
}
