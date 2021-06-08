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
//  TransactionFilterView.swift

import UIKit

class TransactionFilterView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: TransactionFilterViewDelegate?
    
    private(set) lazy var filterOptionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 4.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(
            TransactionFilterOptionCell.self,
            forCellWithReuseIdentifier: TransactionFilterOptionCell.reusableIdentifier
        )
        return collectionView
    }()
    
    private lazy var closeButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withTitle("title-close".localized)
            .withTitleColor(Colors.Text.primary)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
        closeButton.addTarget(self, action: #selector(notifyDelegateToDismissView), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupCloseButtonLayout()
        setupFilterOptionsCollectionViewLayout()
    }
}

extension TransactionFilterView {
    @objc
    private func notifyDelegateToDismissView() {
        delegate?.transactionFilterViewDidDismissView(self)
    }
}

extension TransactionFilterView {
    private func setupCloseButtonLayout() {
        addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
        }
    }
    
    private func setupFilterOptionsCollectionViewLayout() {
        addSubview(filterOptionsCollectionView)
        
        filterOptionsCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(closeButton.snp.top).offset(-layout.current.bottomInset)
        }
    }
}

extension TransactionFilterView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let bottomInset: CGFloat = 16.0
        let topInset: CGFloat = 8.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol TransactionFilterViewDelegate: class {
    func transactionFilterViewDidDismissView(_ transactionFilterView: TransactionFilterView)
}
