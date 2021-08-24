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
//  RekeyConfirmationView.swift

import UIKit
import SnapKit

class RekeyConfirmationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: RekeyConfirmationViewDelegate?
    
    private var collectionViewHeight: Constraint?
    
    private lazy var assetsCollectionView: AssetsCollectionView = {
        let collectionView = AssetsCollectionView(containsPendingAssets: false)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Colors.Background.secondary
        collectionView.contentInset = .zero
        collectionView.layer.cornerRadius = 12.0
        collectionView.register(AlgoAssetCell.self, forCellWithReuseIdentifier: AlgoAssetCell.reusableIdentifier)
        collectionView.register(
            AccountHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AccountHeaderSupplementaryView.reusableIdentifier
        )
        collectionView.register(
            RekeyConfirmationFooterSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: RekeyConfirmationFooterSupplementaryView.reusableIdentifier
        )
        
        return collectionView
    }()
    
    private lazy var transitionTitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withText("ledger-rekey-transaction-title".localized)
    }()
    
    private lazy var rekeyTransitionView = RekeyTransitionView()
    
    private lazy var feeLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.tertiary)
            .withLine(.contained)
            .withAlignment(.left)
    }()
    
    private lazy var finalizeButton = MainButton(title: "ledger-rekey-finalize".localized)
    
    override func configureAppearance() {
        super.configureAppearance()
        rekeyTransitionView.setNewTitleLabel("ledger-rekey-ledger-new".localized)
    }
    
    override func setListeners() {
        finalizeButton.addTarget(self, action: #selector(notifyDelegateToFinalizeRekeyConfirmation), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAssetsCollectionViewLayout()
        setupTransitionTitleLabelLayout()
        setupRekeyTransitionViewLayout()
        setupFeeLabelLayout()
        setupFinalizeButtonLayout()
    }
}

extension RekeyConfirmationView {
    @objc
    private func notifyDelegateToFinalizeRekeyConfirmation() {
        delegate?.rekeyConfirmationViewDidFinalizeConfirmation(self)
    }
}

extension RekeyConfirmationView {
    private func setupAssetsCollectionViewLayout() {
        addSubview(assetsCollectionView)
        
        assetsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(layout.current.horizontalInset)
            collectionViewHeight = make.height.equalTo(layout.current.collectionViewHeight).priority(.high).constraint
        }
    }
    
    private func setupTransitionTitleLabelLayout() {
        addSubview(transitionTitleLabel)
        
        transitionTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(assetsCollectionView.snp.bottom).offset(layout.current.transitionTitleLabelTopInset)
        }
    }
    
    private func setupRekeyTransitionViewLayout() {
        addSubview(rekeyTransitionView)
        
        rekeyTransitionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(transitionTitleLabel.snp.bottom).offset(layout.current.transitionViewTopInset)
        }
    }

    private func setupFeeLabelLayout() {
        addSubview(feeLabel)
        
        feeLabel.snp.makeConstraints { make in
            make.top.equalTo(rekeyTransitionView.snp.bottom).offset(layout.current.feeLabelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupFinalizeButtonLayout() {
        addSubview(finalizeButton)
        
        finalizeButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.greaterThanOrEqualTo(feeLabel.snp.bottom).offset(layout.current.finalizeButtonTopInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
        }
    }
}

extension RekeyConfirmationView {
    func setTransitionOldTitleLabel(_ title: String?) {
        rekeyTransitionView.setOldTitleLabel(title)
    }
    
    func setTransitionOldValueLabel(_ value: String?) {
        rekeyTransitionView.setOldValueLabel(value)
    }
    
    func setTransitionNewValueLabel(_ value: String?) {
        rekeyTransitionView.setNewValueLabel(value)
    }
    
    func reloadData() {
        assetsCollectionView.reloadData()
        let height = assetsCollectionView.collectionViewLayout.collectionViewContentSize.height
        collectionViewHeight?.update(offset: height)
        layoutIfNeeded()
    }
    
    func setListDelegate(_ delegate: UICollectionViewDelegate?) {
        assetsCollectionView.delegate = delegate
    }
    
    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        assetsCollectionView.dataSource = dataSource
    }
    
    func setFeeAmount(_ fee: String?) {
        feeLabel.text = fee
    }
}

extension RekeyConfirmationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let collectionViewHeight: CGFloat = 104.0
        let transitionTitleLabelTopInset: CGFloat = 30.0
        let transitionViewTopInset: CGFloat = 10.0
        let feeLabelTopInset: CGFloat = 16.0
        let finalizeButtonTopInset: CGFloat = 40.0
        let bottomInset: CGFloat = 16.0
    }
}

protocol RekeyConfirmationViewDelegate: AnyObject {
    func rekeyConfirmationViewDidFinalizeConfirmation(_ rekeyConfirmationView: RekeyConfirmationView)
}
