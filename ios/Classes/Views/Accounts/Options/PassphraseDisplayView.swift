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
//  PassphraseDisplayView.swift

import UIKit

class PassphraseDisplayView: BaseView {

    private let layout = Layout<LayoutConstants>()
    
    private lazy var passphraseContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12.0
        view.backgroundColor = Colors.PassphraseDisplayView.containerBackground
        return view
    }()

    private lazy var passphraseCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 6.0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.backgroundColor = .clear
        collectionView.register(PassphraseBackUpCell.self, forCellWithReuseIdentifier: PassphraseBackUpCell.reusableIdentifier)
        return collectionView
    }()

    private lazy var bottomLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.secondary)
            .withLine(.contained)
            .withAlignment(.left)
            .withText("passphrase-bottom-title".localized)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupPassphraseContainerViewLayout()
        setupPassphraseCollectionViewLayout()
        setupBottomLabelLayout()
    }
}

extension PassphraseDisplayView {
    private func setupPassphraseContainerViewLayout() {
        addSubview(passphraseContainerView)

        passphraseContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.containerTopInset)
            make.height.equalTo(layout.current.collectionViewHeight)
        }
    }

    private func setupPassphraseCollectionViewLayout() {
        passphraseContainerView.addSubview(passphraseCollectionView)

        passphraseCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.collectionViewHorizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }

    private func setupBottomLabelLayout() {
        addSubview(bottomLabel)

        bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(passphraseContainerView.snp.bottom).offset(layout.current.bottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
        }
    }
}

extension PassphraseDisplayView {
    func setDelegate(_ delegate: UICollectionViewDelegate?) {
        passphraseCollectionView.delegate = delegate
    }

    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        passphraseCollectionView.dataSource = dataSource
    }
}

extension PassphraseDisplayView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleHorizontalInset: CGFloat = 24.0
        let topInset: CGFloat = 12.0
        let containerTopInset: CGFloat = 36.0
        let collectionViewHeight: CGFloat = 424.0
        let verticalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 16.0
        let collectionViewHorizontalInset: CGFloat = 20.0 * horizontalScale
        let horizontalInset: CGFloat = 20.0
    }
}

extension Colors {
    fileprivate enum PassphraseDisplayView {
        static let containerBackground = color("passphraseContainerBackground")
    }
}
