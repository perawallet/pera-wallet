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
//  TransactionFilterView.swift

import UIKit
import MacaroonUIKit

final class TransactionFilterView: View {
    weak var delegate: TransactionFilterViewDelegate?

    private lazy var theme = TransactionFilterViewTheme()

    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.contentInset)
        collectionView.register(TransactionFilterOptionCell.self)
        return collectionView
    }()

    private lazy var closeButtonContainer = UIView()
    private lazy var closeButton = ViewFactory.Button.makeSecondaryButton("title-close".localized)

    private var isLayoutFinalized = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
        setListeners()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isLayoutFinalized {
            isLayoutFinalized = true

            addLinearGradient()
        }
    }

    func setListeners() {
        closeButton.addTarget(self, action: #selector(notifyDelegateToDismissView), for: .touchUpInside)
    }

    func customize(_ theme: TransactionFilterViewTheme) {
        addCollectionView()
        addCloseButton(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) { }

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension TransactionFilterView {
    @objc
    private func notifyDelegateToDismissView() {
        delegate?.transactionFilterViewDidDismissView(self)
    }
}

extension TransactionFilterView {
    private func addCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addCloseButton(_ theme: TransactionFilterViewTheme) {
        addSubview(closeButtonContainer)
        closeButtonContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.fitToHeight(theme.linearGradientHeight + safeAreaBottom)
        }

        closeButtonContainer.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.bottomInset)
        }
    }

    private func addLinearGradient() {
        let layer = CAGradientLayer()
        layer.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: bounds.width,
                height: theme.linearGradientHeight + safeAreaBottom
            )
        )

        let color0 = Colors.Defaults.background.uiColor.withAlphaComponent(0).cgColor
        let color1 = Colors.Defaults.background.uiColor.cgColor

        layer.colors = [color0, color1]
        closeButtonContainer.layer.insertSublayer(layer, at: 0)
    }
}

extension TransactionFilterView {
    func setCollectionViewDelegate(_ delegate: UICollectionViewDelegate?) {
        collectionView.delegate = delegate
    }

    func setCollectionViewDataSource(_ dataSource: UICollectionViewDataSource?) {
        collectionView.dataSource = dataSource
    }
}

protocol TransactionFilterViewDelegate: AnyObject {
    func transactionFilterViewDidDismissView(_ transactionFilterView: TransactionFilterView)
}
