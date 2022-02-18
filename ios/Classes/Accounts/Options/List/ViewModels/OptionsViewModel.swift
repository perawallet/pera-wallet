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
//  OptionsViewModel.swift

import UIKit

final class OptionsViewModel {
    private(set) var image: UIImage?
    private(set) var title: String?
    private(set) var subtitle: String?
    private(set) var titleColor: UIColor?

    init(option: OptionsViewController.Options, account: Account) {
        bindImage(for: option, with: account)
        bindTitle(for: option, with: account)
        bindSubtitle(for: option, with: account)
        bindTitleColor(for: option)
    }
}

extension OptionsViewModel {
    private func bindImage(for option: OptionsViewController.Options, with account: Account) {
        switch option {
        case .copyAddress:
            image = img("icon-copy")
        case .rekey:
            image = img("icon-options-rekey")
        case .rekeyInformation:
            image = img("icon-qr")
        case .removeAsset:
            image = img("icon-polygon")
        case .viewPassphrase:
            image = img("icon-options-view-passphrase")
        case .muteNotifications:
            image = account.receivesNotification ? img("icon-options-mute-notification") : img("icon-options-unmute-notification")
        case .renameAccount:
            image = img("icon-edit-account")
        case .removeAccount:
            image = img("icon-remove-account")
        }
    }

    private func bindTitle(for option: OptionsViewController.Options, with account: Account) {
        switch option {
        case .copyAddress:
            title = "options-copy-address".localized
        case .rekey:
            title = "options-rekey".localized
        case .rekeyInformation:
            title = "options-auth-account".localized
        case .removeAsset:
            title = "options-manage-assets".localized
        case .viewPassphrase:
            title = "options-view-passphrase".localized
        case .muteNotifications:
            title = account.receivesNotification ? "options-mute-notification".localized : "options-unmute-notification".localized
        case .renameAccount:
            title = "options-edit-account-name".localized
        case .removeAccount:
            title = "options-remove-account".localized
        }
    }

    private func bindTitleColor(for option: OptionsViewController.Options) {
        switch option {
        case .removeAccount:
            titleColor = AppColors.Shared.Helpers.negative.uiColor
        default:
            titleColor = AppColors.Components.Text.main.uiColor
        }
    }

    private func bindSubtitle(for option: OptionsViewController.Options, with account: Account) {
        switch option {
        case .copyAddress:
            subtitle = account.address
        default:
            break
        }
    }
}
