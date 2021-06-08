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
//  OptionsViewModel.swift

import UIKit

class OptionsViewModel {

    private(set) var image: UIImage?
    private(set) var title: String?
    private(set) var titleColor: UIColor?

    init(option: OptionsViewController.Options, account: Account) {
        setImage(for: option, with: account)
        setTitle(for: option, with: account)
        setTitleColor(for: option)
    }

    private func setImage(for option: OptionsViewController.Options, with account: Account) {
        switch option {
        case .rekey:
            image = img("icon-options-rekey")
        case .rekeyInformation:
            image = img("icon-qr")
        case .removeAsset:
            image = img("icon-trash")
        case .passphrase:
            image = img("icon-lock")
        case .notificationSetting:
            image = account.receivesNotification ? img("icon-options-mute-notification") : img("icon-options-unmute-notification")
        case .edit:
            image = img("icon-edit-account")
        case .removeAccount:
            image = img("icon-remove-account")
        }
    }

    private func setTitle(for option: OptionsViewController.Options, with account: Account) {
        switch option {
        case .rekey:
            title = "options-rekey".localized
        case .rekeyInformation:
            title = "options-auth-account".localized
        case .removeAsset:
            title = "options-remove-assets".localized
        case .passphrase:
            title = "options-view-passphrase".localized
        case .notificationSetting:
            title = account.receivesNotification ? "options-mute-notification".localized : "options-unmute-notification".localized
        case .edit:
            title = "options-edit-account-name".localized
        case .removeAccount:
            title = "options-remove-account".localized
        }
    }

    private func setTitleColor(for option: OptionsViewController.Options) {
        switch option {
        case .removeAccount:
            titleColor = Colors.General.error
        default:
            titleColor = Colors.Text.primary
        }
    }
}
