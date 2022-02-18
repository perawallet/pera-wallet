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
//  PassphraseDisplayView.swift

import UIKit
import MacaroonUIKit

final class PassphraseDisplayView: View {
    private lazy var passphraseView = PassphraseView()

    func customize(_ theme: PassphraseDisplayViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addPassphraseView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension PassphraseDisplayView {
    private func addPassphraseView(_ theme: PassphraseDisplayViewTheme) {
        passphraseView.customize(PassphraseViewTheme())

        addSubview(passphraseView)
        passphraseView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().offset(theme.topInset)
            $0.height.equalTo(theme.collectionViewHeight)
        }
    }
}

extension PassphraseDisplayView {
    func setDelegate(_ delegate: UICollectionViewDelegate?) {
        passphraseView.setPassphraseCollectionViewDelegate(delegate)
    }

    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        passphraseView.setPassphraseCollectionViewDataSource(dataSource)
    }
}
