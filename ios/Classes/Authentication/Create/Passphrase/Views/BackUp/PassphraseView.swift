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
//   PassphraseView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class PassphraseView: View {
    private lazy var passphraseContainerView = UIView()

    private lazy var passphraseCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 8
        let passphraseCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        passphraseCollectionView.isScrollEnabled = false
        passphraseCollectionView.showsVerticalScrollIndicator = false
        passphraseCollectionView.showsHorizontalScrollIndicator = false
        passphraseCollectionView.backgroundColor = .clear
        passphraseCollectionView.register(PassphraseCell.self)
        return passphraseCollectionView
    }()

    func customize(_ theme: PassphraseViewTheme) {
        addPassphraseContainerView(theme)
        addPassphraseCollectionView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func reloadData() {
        passphraseCollectionView.reloadData()
    }
}

extension PassphraseView {
    private func addPassphraseContainerView(_ theme: PassphraseViewTheme) {
        passphraseContainerView.customizeAppearance(theme.passphraseContainerView)
        passphraseContainerView.layer.cornerRadius = theme.passphraseContainerCorner.radius

        addSubview(passphraseContainerView)
        passphraseContainerView.pinToSuperview()
    }

    private func addPassphraseCollectionView(_ theme: PassphraseViewTheme) {
        passphraseContainerView.addSubview(passphraseCollectionView)

        passphraseCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.collectionViewHorizontalInset)
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
        }
    }
}

extension PassphraseView {
    func setPassphraseCollectionViewDelegate(_ delegate: UICollectionViewDelegate?) {
        passphraseCollectionView.delegate = delegate
    }

    func setPassphraseCollectionViewDataSource(_ dataSource: UICollectionViewDataSource?) {
        passphraseCollectionView.dataSource = dataSource
    }
}
