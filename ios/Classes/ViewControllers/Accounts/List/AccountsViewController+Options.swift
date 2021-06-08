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
//  AccountsViewController+Options.swift

import UIKit

extension AccountsViewController: OptionsViewControllerDelegate {
    func optionsViewControllerDidOpenRekeying(_ optionsViewController: OptionsViewController) {
        guard let account = selectedAccount else {
            return
        }
        
        open(
            .rekeyInstruction(account: account),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            )
        )
    }
    
    func optionsViewControllerDidRemoveAsset(_ optionsViewController: OptionsViewController) {
        guard let account = selectedAccount else {
            return
        }
        
        let controller = open(
            .removeAsset(account: account),
            by: .customPresent(
                presentationStyle: .fullScreen,
                transitionStyle: nil,
                transitioningDelegate: nil
            )
        ) as? AssetRemovalViewController
        controller?.delegate = self
    }
    
    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController) {
        guard let session = session else {
            return
        }

        if !session.hasPassword() {
            presentPassphraseView()
            return
        }

        if localAuthenticator.localAuthenticationStatus != .allowed {
            let controller = open(
                .choosePassword(mode: .confirm("title-enter-pin-for-passphrase".localized), flow: nil, route: nil),
                by: .present
            ) as? ChoosePasswordViewController
            controller?.delegate = self
            return
        }

        self.localAuthenticator.authenticate { error in
            guard error == nil else {
                return
            }

            self.presentPassphraseView()
        }
    }
    
    private func presentPassphraseView() {
        guard let account = self.selectedAccount else {
            return
        }
        
        open(
            .passphraseDisplay(address: account.address),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: passphraseModalPresenter
            )
        )
    }
    
    func optionsViewControllerDidViewRekeyInformation(_ optionsViewController: OptionsViewController) {
        guard let authAddress = selectedAccount?.authAddress else {
            return
        }
        
        let draft = QRCreationDraft(address: authAddress, mode: .address)
        open(.qrGenerator(title: "options-auth-account".localized, draft: draft), by: .present)
    }
    
    func optionsViewControllerDidRemoveAccount(_ optionsViewController: OptionsViewController) {
        displayRemoveAccountAlert()
    }
    
    private func displayRemoveAccountAlert() {
        let configurator = BottomInformationBundle(
            title: "options-remove-account".localized,
            image: img("img-remove-account"),
            explanation: "options-remove-alert-explanation".localized,
            actionTitle: "options-remove-account".localized,
            actionImage: img("bg-button-red"),
            closeTitle: "title-keep".localized
        ) {
            self.removeAccount()
        }
        
        open(
            .bottomInformation(mode: .action, configurator: configurator),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: removeAccountModalPresenter
            )
        )
    }

    private func removeAccount() {
        guard let user = session?.authenticatedUser,
              let account = selectedAccount,
              let accountInformation = session?.accountInformation(from: account.address) else {
            return
        }

        session?.removeAccount(account)
        user.removeAccount(accountInformation)
        session?.authenticatedUser = user

        if user.accounts.isEmpty {
            setEmptyAccountsState()
        }
    }
}

extension AccountsViewController: ChoosePasswordViewControllerDelegate {
    func choosePasswordViewController(_ choosePasswordViewController: ChoosePasswordViewController, didConfirmPassword isConfirmed: Bool) {
        if isConfirmed {
            presentPassphraseView()
        } else {
            displaySimpleAlertWith(
                title: "password-verify-fail-title".localized,
                message: "options-view-passphrase-password-alert-message".localized
            )
        }
    }
}

extension AccountsViewController: AssetRemovalViewControllerDelegate {
    func assetRemovalViewController(
        _ assetRemovalViewController: AssetRemovalViewController,
        didRemove assetDetail: AssetDetail,
        from account: Account
    ) {
        guard let section = accountsDataSource.section(for: account),
            let index = accountsDataSource.item(for: assetDetail, in: account) else {
            return
        }
        
        accountsDataSource.remove(assetDetail: assetDetail, from: account)
        accountsView.accountsCollectionView.reloadItems(at: [IndexPath(item: index + 1, section: section)])
    }
}
