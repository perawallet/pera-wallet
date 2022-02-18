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
//  PassPhraseBackUpView.swift

import UIKit
import MacaroonUIKit

final class PassphraseBackUpView: View {
    weak var delegate: PassphraseBackUpViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var passphraseView = PassphraseView()
    private(set) lazy var nextButton = Button()

    func customize(_ theme: PassphraseBackUpViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitleLabel(theme)
        addDescriptionLabel(theme)
        addPassphraseView(theme)
        addNextButton(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        nextButton.addTarget(self, action: #selector(notifyDelegateToActionButtonTapped), for: .touchUpInside)
    }
}

extension PassphraseBackUpView {
    @objc
    func notifyDelegateToActionButtonTapped() {
        delegate?.passphraseBackUpViewDidTapActionButton(self)
    }
}

extension PassphraseBackUpView {
    private func addTitleLabel(_ theme: PassphraseBackUpViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topInset)
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addDescriptionLabel(_ theme: PassphraseBackUpViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.bottomInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addPassphraseView(_ theme: PassphraseBackUpViewTheme) {
        passphraseView.customize(theme.passphraseViewTheme)

        addSubview(passphraseView)
        passphraseView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(theme.containerTopInset)
            $0.height.equalTo(theme.collectionViewHeight)
        }
    }

    private func addNextButton(_ theme: PassphraseBackUpViewTheme) {
        nextButton.customize(theme.mainButtonTheme)
        nextButton.bindData(ButtonCommonViewModel(title: "title-next".localized))

        addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.greaterThanOrEqualTo(passphraseView.snp.bottom).offset(theme.containerTopInset)
            $0.bottom.equalToSuperview().inset(theme.bottomInset + safeAreaBottom)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
}

extension PassphraseBackUpView {
    func setPassphraseCollectionViewDelegate(_ delegate: UICollectionViewDelegate?) {
        passphraseView.setPassphraseCollectionViewDelegate(delegate)
    }

    func setPassphraseCollectionViewDataSource(_ dataSource: UICollectionViewDataSource?) {
        passphraseView.setPassphraseCollectionViewDataSource(dataSource)
    }
}

protocol PassphraseBackUpViewDelegate: AnyObject {
    func passphraseBackUpViewDidTapActionButton(_ passphraseView: PassphraseBackUpView)
}
