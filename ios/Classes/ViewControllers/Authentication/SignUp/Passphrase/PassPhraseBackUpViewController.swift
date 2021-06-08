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
//  PassphraseBackUpViewController.swift

import UIKit
import AVFoundation

class PassphraseBackUpViewController: BaseScrollViewController {
    
    private var mnemonics: [String]?
    private var address: String
    private var maxCellWidth: CGFloat?

    private var isDisplayedAllScreen = false
    
    private lazy var passphraseView = PassphraseView()

    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .backgroundTouch
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 338.0))
    )
    
    init(address: String, configuration: ViewControllerConfiguration) {
        self.address = address
        super.init(configuration: configuration)
        generatePrivateKey()
        mnemonics = session?.mnemonics(forAccount: address)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateVerifyButtonAfterScroll()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        setTertiaryBackgroundColor()
        view.backgroundColor = Colors.Background.tertiary
        scrollView.backgroundColor = Colors.Background.tertiary
        contentView.backgroundColor = Colors.Background.tertiary
        passphraseView.verifyButton.isEnabled = false
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupPassphraseViewLayout()
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
        passphraseView.delegate = self
        passphraseView.setDelegate(self)
        passphraseView.setDataSource(self)
        scrollView.delegate = self
    }
}

extension PassphraseBackUpViewController {
    private func setupPassphraseViewLayout() {
        contentView.addSubview(passphraseView)
        
        passphraseView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension PassphraseBackUpViewController: UICollectionViewDataSource {
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

extension PassphraseBackUpViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2.0, height: 24.0)
    }
}

extension PassphraseBackUpViewController: PassphraseBackUpViewDelegate {
    func passphraseViewDidTapActionButton(_ passphraseView: PassphraseView) {
        open(.passphraseVerify, by: .push)
    }
}

extension PassphraseBackUpViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateVerifyButtonAfterScroll()
    }

    private func updateVerifyButtonAfterScroll() {
        // Enable moving to next screen if the whole screen is displayed by scrolling. 

        if isDisplayedAllScreen {
            return
        }

        if isVerifyButtonDisplayed() {
            isDisplayedAllScreen = true
            passphraseView.verifyButton.isEnabled = true
        }
    }

    private func isVerifyButtonDisplayed() -> Bool {
        return scrollView.bounds.contains(passphraseView.verifyButton.frame)
    }
}

extension PassphraseBackUpViewController {
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

extension PassphraseBackUpViewController {
    private func generatePrivateKey() {
        guard let session = self.session,
            let privateKey = session.generatePrivateKey() else {
                return
        }
        
        session.savePrivate(privateKey, for: address)
    }
}
