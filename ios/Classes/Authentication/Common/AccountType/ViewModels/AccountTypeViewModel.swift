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
    private(set) var title: EditText?
    private(set) var detail: EditText?
    private(set) var badge: String?
    
    init(_ model: AccountSetupMode) {
        bindImage(model)
        bindTitle(model)
        bindDetail(model)
    }
}

extension AccountTypeViewModel {
    private mutating func bindImage(_ mode: AccountSetupMode) {
        switch mode {
        case .add:
            image = img("icon-add-account")
        case let .recover(type):
            switch type {
            case .none, .passphrase:
                image = img("icon-recover-passphrase")
            case .importFromSecureBackup:
                image = img("icon-import-from-secure-backup")
            case .ledger:
                image = img("icon-pair-ledger-account")
            case .importFromWeb:
                image = img("icon-import-from-web")
            case .qr:
                image = img("icon-recover-qr")
            }
        case .watch:
            image = img("icon-add-watch-account")
        case .rekey,
             .none:
            break
        }
    }
    
    private mutating func bindTitle(_ mode: AccountSetupMode) {
        var attributes = Typography.bodyMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.main))
        var titleText: String = ""
        
        switch mode {
        case .add:
            titleText = "account-type-selection-create".localized
        case let .recover(type):
            switch type {
            case .passphrase:
                titleText = "account-type-selection-passphrase".localized
            case .importFromSecureBackup:
                titleText = "account-type-selection-import-secure-backup".localized
            case .ledger:
                titleText = "account-type-selection-ledger".localized
            case .importFromWeb:
                titleText = "account-type-selection-import-web".localized
            case .qr:
                titleText = "account-type-selection-qr".localized
            case .none:
                titleText = "account-type-selection-recover".localized
            }
        case .watch:
            titleText = "account-type-selection-watch".localized
        case .rekey,
             .none:
            break
        }
        
        title = .attributedString(titleText.attributed(attributes))
    }

    private mutating func bindBadge(_ mode: AccountSetupMode) {
        switch mode {
        case let .recover(type):
            switch type {
            case .importFromWeb, .importFromSecureBackup:
                badge = "title-new-uppercased".localized
            default:
                break
            }
        default:
            break
        }
    }

    private mutating func bindDetail(_ mode: AccountSetupMode) {
        var attributes = Typography.footnoteRegularAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.gray))
        var detailText: String = ""
        
        switch mode {
        case .add:
            detailText = "account-type-selection-add-detail".localized
        case let .recover(type):
            switch type {
            case .passphrase:
                detailText = "account-type-selection-passphrase-detail".localized
            case .importFromSecureBackup:
                detailText = "account-type-selection-import-secure-backup-detail".localized
            case .ledger:
                detailText = "account-type-selection-ledger-detail".localized
            case .importFromWeb:
                detailText = "account-type-selection-import-web-detail".localized
            case .qr:
                detailText = "account-type-selection-qr-detail".localized
            case .none:
                detailText = "account-type-selection-recover-detail".localized
            }
        case .watch:
            detailText = "account-type-selection-watch-detail".localized
        case .rekey,
             .none:
            break
        }
        
        detail = .attributedString(detailText.attributed(attributes))
    }
}
