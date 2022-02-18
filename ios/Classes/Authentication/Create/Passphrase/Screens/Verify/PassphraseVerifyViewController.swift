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
//  PassphraseVerifyViewController.swift

import UIKit
import AVFoundation

final class PassphraseVerifyViewController: BaseScrollViewController {
    private lazy var passphraseVerifyView = PassphraseVerifyView()
    private lazy var theme = Theme()

    private lazy var layoutBuilder: PassphraseVerifyLayoutBuilder = {
        return PassphraseVerifyLayoutBuilder(dataSource: dataSource, theme: theme)
    }()

    private lazy var accountOrdering = AccountOrdering(
        sharedDataController: sharedDataController,
        session: session!
    )

    private lazy var dataSource: PassphraseVerifyDataSource = {
        if let privateKey = session?.privateData(for: "temp") {
            return PassphraseVerifyDataSource(privateKey: privateKey)
        }
        fatalError("Private key should be set.")
    }()

    private let flow: AccountSetupFlow

    init(
        flow: AccountSetupFlow,
        configuration: ViewControllerConfiguration
    ) {
        self.flow = flow
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()
        customizeBackground()
        passphraseVerifyView.setNextButtonEnabled(false)
    }

    private func customizeBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        scrollView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        passphraseVerifyView.setCollectionViewDelegate(layoutBuilder)
        passphraseVerifyView.setCollectionViewDataSource(dataSource)
        passphraseVerifyView.delegate = self
        dataSource.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()        
        contentView.addSubview(passphraseVerifyView)
        passphraseVerifyView.pinToSuperview()
    }
}

extension PassphraseVerifyViewController: PassphraseVerifyDataSourceDelegate {
    func passphraseVerifyDataSource(_ passphraseVerifyDataSource: PassphraseVerifyDataSource, isSelectedAllItems: Bool) {
        passphraseVerifyView.setNextButtonEnabled(isSelectedAllItems)
    }
}

extension PassphraseVerifyViewController: PassphraseVerifyViewDelegate {
    func passphraseVerifyViewDidVerifyPassphrase(_ passphraseVerifyView: PassphraseVerifyView) {
        if !dataSource.isSelectedValidMnemonics(
            for: passphraseVerifyView.passphraseCollectionView.indexPathsForSelectedItems
        ) {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "passphrase-verify-wrong-message".localized
            )
            dataSource.resetVerificationData()
            passphraseVerifyView.resetSelectionStatesAndReloadData()
            return
        }

        guard let account = createAccount() else {
            return
        }

        open(
            .tutorial(flow: flow, tutorial: .passphraseVerified(account: account)),
            by: .push
        )
    }

    private func createAccount() -> AccountInformation? {
        guard let tempPrivateKey = session?.privateData(for: "temp"),
            let address = session?.address(for: "temp") else {
                return nil
        }

        log(RegistrationEvent(type: .create))

        let account = AccountInformation(
            address: address,
            name: address.shortAddressDisplay(),
            type: .standard,
            preferredOrder: accountOrdering.getNewAccountIndex(for: .standard)
        )
        session?.savePrivate(tempPrivateKey, for: account.address)
        session?.removePrivateData(for: "temp")

        if let authenticatedUser = session?.authenticatedUser {
            authenticatedUser.addAccount(account)
        } else {
            let user = User(accounts: [account])
            session?.authenticatedUser = user
        }

        NotificationCenter.default.post(
            name: .didAddAccount,
            object: self
        )

        return account
    }
}
