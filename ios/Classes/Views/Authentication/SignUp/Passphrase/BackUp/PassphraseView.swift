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
//  PassPhraseBackUpView.swift

import UIKit

class PassphraseView: BaseView {
    
    weak var delegate: PassphraseBackUpViewDelegate?
    
    private let layout = Layout<LayoutConstants>()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 28.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.center)
            .withText("recover-passphrase-title".localized)
    }()
    
    private lazy var passphraseContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12.0
        view.backgroundColor = Colors.PassphraseView.containerBackground
        return view
    }()
    
    private lazy var passphraseCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 8.0
        
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
    
    private(set) lazy var verifyButton = MainButton(title: "title-next".localized)
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func setListeners() {
        verifyButton.addTarget(self, action: #selector(notifyDelegateToActionButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupPassphraseContainerViewLayout()
        setupPassphraseCollectionViewLayout()
        setupBottomLabelLayout()
        setupVerifyButtonLayout()
    }
}

extension PassphraseView {
    @objc
    func notifyDelegateToActionButtonTapped() {
        delegate?.passphraseViewDidTapActionButton(self)
    }
}

extension PassphraseView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.titleHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupPassphraseContainerViewLayout() {
        addSubview(passphraseContainerView)
        
        passphraseContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.containerTopInset)
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
        }
    }

    private func setupVerifyButtonLayout() {
        addSubview(verifyButton)
        
        verifyButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.greaterThanOrEqualTo(bottomLabel.snp.bottom).offset(layout.current.containerTopInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension PassphraseView {
    func setDelegate(_ delegate: UICollectionViewDelegate?) {
        passphraseCollectionView.delegate = delegate
    }

    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        passphraseCollectionView.dataSource = dataSource
    }
}

extension PassphraseView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleHorizontalInset: CGFloat = 24.0
        let topInset: CGFloat = 12.0
        let containerTopInset: CGFloat = 28.0
        let collectionViewHeight: CGFloat = 448.0
        let verticalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 16.0
        let collectionViewHorizontalInset: CGFloat = 20.0 * horizontalScale
        let horizontalInset: CGFloat = 20.0
    }
}

extension Colors {
    fileprivate enum PassphraseView {
        static let containerBackground = color("passphraseContainerBackground")
    }
}

protocol PassphraseBackUpViewDelegate: class {
    func passphraseViewDidTapActionButton(_ passphraseView: PassphraseView)
}
