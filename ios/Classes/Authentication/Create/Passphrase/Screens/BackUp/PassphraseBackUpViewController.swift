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
//  PassphraseBackUpViewController.swift

import UIKit
import AVFoundation

final class PassphraseBackUpViewController: BaseScrollViewController {
    private var mnemonics: [String]?
    private var address: String
    private var isDisplayedAllScreen = false

    private lazy var passphraseBackUpView = PassphraseBackUpView()
    private lazy var theme = Theme()

    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!
    )

    private lazy var bottomModalTransition = BottomSheetTransition(presentingViewController: self)

    private let flow: AccountSetupFlow

    init(
        flow: AccountSetupFlow,
        address: String,
        configuration: ViewControllerConfiguration
    ) {
        self.flow = flow
        self.address = address
        super.init(configuration: configuration)

        if !flow.isBackUpAccount {
            generatePrivateKey()
        }

        mnemonics = session?.mnemonics(forAccount: address)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        addNavigationBarButtonItemsIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateVerifyButtonAfterScroll()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
    }

    override func configureAppearance() {
        super.configureAppearance()
        customizeBackground()
        passphraseBackUpView.nextButton.isEnabled = false
    }

    private func customizeBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        scrollView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        contentView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addPassphraseView()
    }

    override func setListeners() {
        super.setListeners()
        passphraseBackUpView.setListeners()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(displayScreenshotWarning),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
    }
    
    override func linkInteractors() {
        passphraseBackUpView.delegate = self
        passphraseBackUpView.setPassphraseCollectionViewDelegate(self)
        passphraseBackUpView.setPassphraseCollectionViewDataSource(self)
        scrollView.delegate = self
    }
}

extension PassphraseBackUpViewController {
    private func addNavigationBarButtonItemsIfNeeded() {
        guard !flow.isBackUpAccount else { return }

        rightBarButtonItems = [ makeSkipBarButtonItem() ]
    }

    private func makeSkipBarButtonItem() -> ALGBarButtonItem {
        return ALGBarButtonItem(kind: .skip) {
            [unowned self] in
            guard let account = createAccount() else { return }
            self.navigateToSetupNameScreen(account)
        }
    }
}

extension PassphraseBackUpViewController {
    private func navigateToSetupNameScreen(_ account: AccountInformation) {
        let screen = open(
            .accountNameSetup(
                flow: flow,
                mode: .add,
                accountAddress: account.address
            ),
            by: .push 
        ) as? AccountNameSetupViewController
        screen?.hidesCloseBarButtonItem = true
        screen?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}

extension PassphraseBackUpViewController {
    private func addPassphraseView() {
        passphraseBackUpView.customize(theme.passphraseBackUpViewTheme)

        contentView.addSubview(passphraseBackUpView)
        passphraseBackUpView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension PassphraseBackUpViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mnemonics?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(PassphraseCell.self, at: indexPath)
        let passphrase = Passphrase(index: indexPath.item, mnemonics: mnemonics)
        cell.bindData(PassphraseCellViewModel(passphrase))
        return cell
    }
}

extension PassphraseBackUpViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2, height: theme.cellHeight)
    }
}

extension PassphraseBackUpViewController: PassphraseBackUpViewDelegate {
    func passphraseBackUpViewDidTapActionButton(_ passphraseView: PassphraseBackUpView) {
        analytics.track(.onboardCreateAccountPassphrase(type: .copy))
       
        open(
            .passphraseVerify(
                flow: flow,
                address: address
            ),
            by: .push
        )
    }
}

extension PassphraseBackUpViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateVerifyButtonAfterScroll()
    }

    private func updateVerifyButtonAfterScroll() {
        /// <note> Enable moving to next screen if the whole screen is displayed by scrolling.
        if isDisplayedAllScreen {
            return
        }

        if isVerifyButtonDisplayed() {
            isDisplayedAllScreen = true
            passphraseBackUpView.nextButton.isEnabled = true
        }
    }

    private func isVerifyButtonDisplayed() -> Bool {
        return scrollView.bounds.contains(passphraseBackUpView.nextButton.frame)
    }
}

extension PassphraseBackUpViewController {
    @objc
    private func displayScreenshotWarning() {
        /// <note> Display screenshot detection warning if the user takes a screenshot of passphrase
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        bottomModalTransition.perform(
            .bottomWarning(
                configurator:
                    BottomWarningViewConfigurator(
                        image: "icon-info-red".uiImage,
                        title: "screenshot-title".localized,
                        description: .plain("screenshot-description".localized),
                        secondaryActionButtonTitle: "title-close".localized
                    )
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension PassphraseBackUpViewController {
    private func createAccount() -> AccountInformation? {
        guard
            let tempPrivateKey = session?.privateData(for: "temp"),
            let address = session?.address(for: "temp")
        else {
            return nil
        }

        analytics.track(.registerAccount(registrationType: .create))

        let account = AccountInformation(
            address: address,
            name: address.shortAddressDisplay,
            isWatchAccount: false,
            preferredOrder: sharedDataController.getPreferredOrderForNewAccount(),
            isBackedUp: false
        )
        session?.savePrivate(tempPrivateKey, for: account.address)
        session?.removePrivateData(for: "temp")

        if let authenticatedUser = session?.authenticatedUser {
            authenticatedUser.addAccount(account)
            pushNotificationController.sendDeviceDetails()
        } else {
            let user = User(accounts: [account])
            session?.authenticatedUser = user
        }

        return account
    }

    private func generatePrivateKey() {
        guard let session = session,
              let privateKey = session.generatePrivateKey() else {
            return
        }
        
        session.savePrivate(privateKey, for: address)
    }
}
