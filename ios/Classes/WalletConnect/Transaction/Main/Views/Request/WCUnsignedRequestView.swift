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
    private lazy var confirmButton = Button()
    private lazy var cancelButton = Button()

    private lazy var theme = WCUnsignedRequestViewTheme()

    override func configureAppearance() {
        super.configureAppearance()

        backgroundColor = theme.backgroundColor.uiColor

        confirmButton.customize(theme.confirmButton)
        confirmButton.setTitle("title-confirm-all".localized, for: .normal)
        cancelButton.customize(theme.cancelButton)
        cancelButton.setTitle("title-cancel".localized, for: .normal)
    }

    override func linkInteractors() {
        super.linkInteractors()

        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }

    override func prepareLayout() {
        super.prepareLayout()

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
    private func addButtons() {
        addButtonsGradient()
        addSubview(buttonsContainerView)
        buttonsContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(theme.buttonContainerHeight)
            make.bottom.equalToSuperview()
        }

        buttonsContainerView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(theme.buttonBottomInset)
            make.leading.equalToSuperview().inset(theme.horizontalPadding)
            make.height.equalTo(theme.buttonHeight)
        }

        buttonsContainerView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(theme.buttonBottomInset)
            make.leading.equalTo(cancelButton.snp.trailing).offset(theme.buttonPadding)
            make.trailing.equalToSuperview().inset(theme.horizontalPadding)
            make.height.equalTo(cancelButton)
            make.width.equalTo(cancelButton).multipliedBy(theme.confirmButtonWidthMultiplier)
        }
    }

    private func addCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func addButtonsGradient() {
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = CGSize(width: UIScreen.main.bounds.width, height: theme.buttonContainerHeight)
        layer.frame.origin = .zero

        let color0 = Colors.Defaults.background.uiColor.withAlphaComponent(0).cgColor
        let color1 = Colors.Defaults.background.uiColor.cgColor

        layer.colors = [color0, color1]
        buttonsContainerView.layer.insertSublayer(layer, at: 0)
    }
}
