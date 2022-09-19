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
//  PassphraseDisplayViewController.swift

import UIKit
import AVFoundation
import MacaroonBottomSheet
import MacaroonUIKit

final class PassphraseDisplayViewController: BaseScrollViewController {
    private lazy var theme = Theme()
    private lazy var passphraseDisplayView = PassphraseDisplayView()

    private lazy var bottomModalTransition = BottomSheetTransition(presentingViewController: self)

    private var mnemonics: [String]? {
        guard let session = session else {
            return nil
        }
        let mnemonics = session.mnemonics(forAccount: address)
        return mnemonics
    }

    private var address: String

    init(address: String, configuration: ViewControllerConfiguration) {
        self.address = address
        super.init(configuration: configuration)
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
        title = "options-passphrase".localized
    }

    private func customizeBackground() {
        scrollView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func setListeners() {
        super.setListeners()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(displayScreenshotWarning),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        passphraseDisplayView.setDelegate(self)
        passphraseDisplayView.setDataSource(self)
    }

    override func prepareLayout() {
        super.prepareLayout()
        passphraseDisplayView.customize(theme.passphraseDisplayViewTheme)
        contentView.addSubview(passphraseDisplayView)
        passphraseDisplayView.pinToSuperview()
    }
}

extension PassphraseDisplayViewController: BottomSheetScrollPresentable {
    var modalHeight: ModalHeight {
        return .preferred(theme.modalHeight)
    }
}

extension PassphraseDisplayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mnemonics?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(PassphraseCell.self, at: indexPath)
        cell.bindData(PassphraseCellViewModel(Passphrase(index: indexPath.item, mnemonics: mnemonics)))
        return cell
    }
}

extension PassphraseDisplayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2, height: theme.cellHeight)
    }
}

extension PassphraseDisplayViewController {
    @objc
    private func displayScreenshotWarning() {
        /// <note> Display screenshot detection warning if the user takes a screenshot of passphrase
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        bottomModalTransition.perform(
            .bottomWarning(
                configurator: BottomWarningViewConfigurator(
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
