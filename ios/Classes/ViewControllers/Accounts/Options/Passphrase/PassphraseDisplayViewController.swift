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
//  PassphraseDisplayViewController.swift

import UIKit
import AVFoundation

class PassphraseDisplayViewController: BaseScrollViewController {

    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .backgroundTouch
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 338.0))
    )
    
    var mnemonics: [String]? {
        guard let session = self.session else {
            return nil
        }
        let mnemonics = session.mnemonics(forAccount: address)
        return mnemonics
    }
    
    private var address: String
    
    private lazy var passphraseDisplayView = PassphraseDisplayView()
    
    init(address: String, configuration: ViewControllerConfiguration) {
        self.address = address
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            self?.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = Colors.Background.secondary
        title = "options-view-passphrase".localized
        setSecondaryBackgroundColor()
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
        setupPassphraseViewLayout()
    }
}

extension PassphraseDisplayViewController {
    private func setupPassphraseViewLayout() {
        contentView.addSubview(passphraseDisplayView)
        passphraseDisplayView.pinToSuperview()
    }
}

extension PassphraseDisplayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mnemonics?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PassphraseBackUpCell.reusableIdentifier,
            for: indexPath
        ) as? PassphraseBackUpCell {
            cell.bind(PassphraseBackUpOrderViewModel(mnemonics: mnemonics, index: indexPath.item))
            return cell
        }

        fatalError("Index path is out of bounds")
    }
}

extension PassphraseDisplayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2.0, height: 22.0)
    }
}

extension PassphraseDisplayViewController {
    @objc
    private func displayScreenshotWarning() {
        // Display screenshot detection warning if the user takes a screenshot of passphrase
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        open(
            .screenshotWarning,
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: bottomModalPresenter
            )
        )
    }
}
