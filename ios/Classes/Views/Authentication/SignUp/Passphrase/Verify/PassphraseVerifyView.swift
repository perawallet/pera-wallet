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
//  PassPhraseVerifyView.swift

import UIKit

class PassphraseVerifyView: BaseView {

    weak var delegate: PassphraseVerifyViewDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var titleLabel: UILabel = {
        UILabel(frame: .zero)
            .withFont(UIFont.font(withWeight: .semiBold(size: 28.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.center)
            .withText("passphrase-verify-title".localized)
    }()
    
    private lazy var passphraseCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0.0
        collectionViewLayout.minimumInteritemSpacing = layout.current.cellSpacing
        collectionViewLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(PassphraseMnemonicCell.self, forCellWithReuseIdentifier: PassphraseMnemonicCell.reusableIdentifier)
        collectionView.register(
            PasshraseMnemonicNumberHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PasshraseMnemonicNumberHeaderSupplementaryView.reusableIdentifier
        )
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = true
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var verifyButton = MainButton(title: "title-next".localized)

    override func prepareLayout() {
        setuptTitleLabelLayout()
        setupCollectionViewLayout()
        setupWrongChoiceLabelLayout()
    }

    override func setListeners() {
        verifyButton.addTarget(self, action: #selector(notifyDelegateToVerifyPassphrase), for: .touchUpInside)
    }
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
}

extension PassphraseVerifyView {
    private func setuptTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { maker in
            maker.top.equalToSuperview().inset(layout.current.titleTopInset)
            maker.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupCollectionViewLayout() {
        addSubview(passphraseCollectionView)
        
        passphraseCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.listTopOffset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.listHeight)
        }
    }
    
    private func setupWrongChoiceLabelLayout() {
        addSubview(verifyButton)
        
        verifyButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(passphraseCollectionView.snp.bottom).offset(layout.current.buttonVerticalInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.buttonVerticalInset)
        }
    }
}

extension PassphraseVerifyView {
    func setDelegate(_ delegate: UICollectionViewDelegate?) {
        passphraseCollectionView.delegate = delegate
    }

    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        passphraseCollectionView.dataSource = dataSource
    }

    func setVerificationEnabled(_ isEnabled: Bool) {
        verifyButton.isEnabled = isEnabled
    }

    func resetSelectionStatesAndReloadData() {
        passphraseCollectionView.indexPathsForSelectedItems?.forEach { passphraseCollectionView.deselectItem(at: $0, animated: false) }
        passphraseCollectionView.reloadData()
    }
}

extension PassphraseVerifyView {
    @objc
    private func notifyDelegateToVerifyPassphrase() {
        delegate?.passphraseVerifyViewDidVerifyPassphrase(self)
    }
}

extension PassphraseVerifyView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleTopInset: CGFloat = 12.0
        let horizontalInset: CGFloat = 20.0
        let buttonVerticalInset: CGFloat = 16.0
        let listTopOffset: CGFloat = 60.0
        let listHeight: CGFloat = 440.0
        let cellSpacing: CGFloat = 18.0
    }
}

protocol PassphraseVerifyViewDelegate: class {
    func passphraseVerifyViewDidVerifyPassphrase(_ passphraseVerifyView: PassphraseVerifyView)
}
