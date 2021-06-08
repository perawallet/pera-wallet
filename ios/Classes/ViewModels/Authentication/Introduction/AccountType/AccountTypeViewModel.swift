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
//  AccountTypeViewModel.swift

import UIKit

class AccountTypeViewModel {
    
    private(set) var typeImage: UIImage?
    private(set) var title: String?
    private(set) var detail: String?
    
    init(accountSetupMode: AccountSetupMode) {
        setTypeImage(for: accountSetupMode)
        setTitle(for: accountSetupMode)
        setDetail(for: accountSetupMode)
    }
    
    private func setTypeImage(for accountSetupMode: AccountSetupMode) {
        switch accountSetupMode {
        case let .add(type):
            switch type {
            case .create:
                typeImage = img("icon-create-new-account")
            case .watch:
                typeImage = img("icon-add-watch-account")
            case .pair:
                typeImage = img("icon-pair-ledger-account")
            case .none:
                typeImage = img("icon-add-account")
            }
        case .recover:
            typeImage = img("icon-recover-passphrase")
        case .rekey,
             .none:
            break
        }
    }
    
    private func setTitle(for accountSetupMode: AccountSetupMode) {
        switch accountSetupMode {
        case let .add(type):
            switch type {
            case .create:
                title = "account-type-selection-create".localized
            case .watch:
                title = "title-watch-account".localized
            case .pair:
                title = "account-type-selection-ledger".localized
            case .none:
                title = "account-type-selection-add".localized
            }
        case .recover:
            title = "account-type-selection-recover".localized
        case .rekey,
             .none:
            break
        }
    }

    private func setDetail(for accountSetupMode: AccountSetupMode) {
        switch accountSetupMode {
        case let .add(type):
            switch type {
            case .create:
                detail = "account-type-selection-add-detail".localized
            case .watch:
                detail = "account-type-selection-watch-detail".localized
            case .pair:
                detail = "account-type-selection-ledger-detail".localized
            case .none:
                detail = "account-type-selection-create-detail".localized
            }
        case .recover:
            detail = "account-type-selection-recover-detail".localized
        case .rekey,
             .none:
            break
        }
    }
}
