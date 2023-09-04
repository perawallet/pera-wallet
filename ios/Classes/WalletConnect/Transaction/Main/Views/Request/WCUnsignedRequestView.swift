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
//   WCUnsignedRequestView.swift

import Foundation
import UIKit
import MacaroonUIKit

protocol WCUnsignedRequestViewDelegate: AnyObject {
    func wcUnsignedRequestViewDidTapCancel(_ requestView: WCUnsignedRequestView)
    func wcUnsignedRequestViewDidTapConfirm(_ requestView: WCUnsignedRequestView)
}

final class WCUnsignedRequestView: BaseView {
    weak var delegate: WCUnsignedRequestViewDelegate?

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 12.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 36, left: 0, bottom: theme.collectionViewBottomOffset, right: 0)
        collectionView.register(
            WCMultipleTransactionItemCell.self,
            forCellWithReuseIdentifier: WCMultipleTransactionItemCell.reusableIdentifier
        )
        collectionView.register(
            WCGroupTransactionItemCell.self,
            forCellWithReuseIdentifier: WCGroupTransactionItemCell.reusableIdentifier
        )
        collectionView.register(
            WCAppCallTransactionItemCell.self,
            forCellWithReuseIdentifier: WCAppCallTransactionItemCell.reusableIdentifier
        )
        collectionView.register(
            WCGroupAnotherAccountTransactionItemCell.self,
            forCellWithReuseIdentifier: WCGroupAnotherAccountTransactionItemCell.reusableIdentifier
        )
        collectionView.register(
            WCAssetConfigTransactionItemCell.self,
            forCellWithReuseIdentifier: WCAssetConfigTransactionItemCell.reusableIdentifier
        )
        collectionView.register(
            WCAssetConfigAnotherAccountTransactionItemCell.self,
            forCellWithReuseIdentifier: WCAssetConfigAnotherAccountTransactionItemCell.reusableIdentifier
        )
        return collectionView
    }()

    private lazy var buttonsContainerView = UIView()
    private lazy var confirmButton = MacaroonUIKit.Button()
    private lazy var cancelButton = MacaroonUIKit.Button()

    private lazy var theme = WCUnsignedRequestViewTheme()

    override func prepareLayout() {
        super.prepareLayout()

        addBackground()
        addCollectionView()
        addButtons()
    }
}

extension WCUnsignedRequestView {
    @objc
    private func didTapCancel() {
        delegate?.wcUnsignedRequestViewDidTapCancel(self)
    }

    @objc
    private func didTapConfirm() {
        delegate?.wcUnsignedRequestViewDidTapConfirm(self)
    }
}

extension WCUnsignedRequestView {
    func setDelegate(_ delegate: UICollectionViewDelegate?) {
        collectionView.delegate = delegate
    }

    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        collectionView.dataSource = dataSource
    }

    func reloadData() {
        collectionView.reloadData()
    }
}

extension WCUnsignedRequestView {
    private func addBackground() {
        backgroundColor = theme.backgroundColor.uiColor
    }

    private func addButtons() {
        addButtonsGradient()
        addSubview(buttonsContainerView)
        buttonsContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(theme.collectionViewBottomOffset)
            make.bottom.equalToSuperview()
        }

        cancelButton.customizeAppearance(theme.cancelButton)
        buttonsContainerView.addSubview(cancelButton)
        cancelButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)
        cancelButton.snp.makeConstraints { make in
            let safeAreaBottom = compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.buttonBottomPadding
            make.bottom.equalToSuperview().inset(bottom)
            make.leading.equalToSuperview().inset(theme.horizontalPadding)
        }

        cancelButton.addTouch(
            target: self,
            action: #selector(didTapCancel)
        )

        confirmButton.customizeAppearance(theme.confirmButton)
        buttonsContainerView.addSubview(confirmButton)
        confirmButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)
        confirmButton.snp.makeConstraints { make in
            let safeAreaBottom = compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.buttonBottomPadding
            make.bottom.equalToSuperview().inset(bottom)
            make.leading.equalTo(cancelButton.snp.trailing).offset(theme.buttonHorizontalPadding)
            make.trailing.equalToSuperview().inset(theme.horizontalPadding)
            make.width.equalTo(cancelButton).multipliedBy(theme.confirmButtonWidthMultiplier)
        }

        confirmButton.addTouch(
            target: self,
            action: #selector(didTapConfirm)
        )
    }

    private func addCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func addButtonsGradient() {
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = CGSize(width: UIScreen.main.bounds.width, height: theme.collectionViewBottomOffset)
        layer.frame.origin = .zero

        let color0 = Colors.Defaults.background.uiColor.withAlphaComponent(0).cgColor
        let color1 = Colors.Defaults.background.uiColor.cgColor

        layer.colors = [color0, color1]
        buttonsContainerView.layer.insertSublayer(layer, at: 0)
    }
}
