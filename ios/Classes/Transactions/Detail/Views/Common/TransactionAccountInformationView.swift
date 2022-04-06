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
//  TransactionAccountInformationView.swift

import UIKit

class TransactionAccountInformationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: TransactionAccountInformationViewDelegate?
    
    private lazy var titleLabel = TransactionDetailTitleLabel()
    
    private lazy var containerView = UIView()
    
    private lazy var accountNameView = ImageWithTitleView()
    
    private lazy var separatorView = UIView()
    
    private lazy var assetNameView = AssetNameView()
    
    private lazy var amountLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.right)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private lazy var removeButton = UIButton().withImage(img("img-remove-sender"))
    
    override func configureAppearance() {
        super.configureAppearance()
        titleLabel.text = "asset-title".localized
        containerView.backgroundColor = Colors.Background.disabled
        separatorView.backgroundColor = Colors.Component.separator
        removeButton.isHidden = true
        containerView.layer.cornerRadius = 12.0
    }
    
    override func setListeners() {
        removeButton.addTarget(self, action: #selector(notifyDelegateToRemoveView), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupContainerViewLayout()
        setupRemoveButtonLayout()
        setupAccountNameViewLayout()
        setupSeparatorViewLayout()
        setupAssetNameViewLayout()
        setupAmountLabelLayout()
    }
}

extension TransactionAccountInformationView {
    @objc
    private func notifyDelegateToRemoveView() {
        delegate?.transactionAccountInformationViewDidTapRemoveButton(self)
    }
}

extension TransactionAccountInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.titleLeadingInset)
            make.top.equalToSuperview()
        }
    }
    
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.containerTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.containerHorizontalInset)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupRemoveButtonLayout() {
        containerView.addSubview(removeButton)
        
        removeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.buttonTrailingInset)
            make.size.equalTo(layout.current.buttonSize)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupAccountNameViewLayout() {
        containerView.addSubview(accountNameView)
        
        accountNameView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    private func setupSeparatorViewLayout() {
        containerView.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset).priority(.low)
            make.trailing.equalTo(removeButton.snp.leading).offset(-layout.current.buttonTrailingInset)
            make.top.equalTo(accountNameView.snp.bottom).offset(layout.current.verticalInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupAssetNameViewLayout() {
        containerView.addSubview(assetNameView)
        
        assetNameView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(separatorView.snp.bottom).offset(layout.current.verticalInset)
            make.bottom.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.lessThanOrEqualTo(separatorView).priority(.low)
        }
    }
    
    private func setupAmountLabelLayout() {
        containerView.addSubview(amountLabel)
        
        amountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(separatorView)
            make.centerY.equalTo(assetNameView)
            make.leading.equalTo(assetNameView.snp.trailing).offset(layout.current.minimumOffset)
        }
    }
}

extension TransactionAccountInformationView {
    func setEnabled() {
        containerView.backgroundColor = Colors.Background.secondary
        removeButton.isHidden = false
        separatorView.backgroundColor = Colors.Component.separator
    }
    
    func setDisabled() {
        containerView.backgroundColor = Colors.Background.disabled
        removeButton.removeFromSuperview()
        separatorView.backgroundColor = Colors.Component.separator
    }
    
    func setAccountImage(_ image: UIImage?) {
        accountNameView.setAccountImage(image)
    }
    
    func setAccountName(_ name: String?) {
        accountNameView.setAccountName(name)
    }
    
    func setAmount(_ amount: String?) {
        amountLabel.text = amount
    }
    
    func removeAmountLabel() {
        amountLabel.removeFromSuperview()
    }
    
    func setAssetName(for assetDetail: StandardAsset) {
        assetNameView.setAssetName(for: assetDetail)
    }
    
    func setAssetName(_ name: String) {
        assetNameView.setName(name)
    }
    
    func setAssetCode(_ code: String) {
        assetNameView.setCode(code)
    }
    
    func setAssetId(_ id: String) {
        assetNameView.setId(id)
    }
    
    func removeVerifiedAsset() {
        assetNameView.removeVerified()
    }
    
    func removeAssetId() {
        assetNameView.removeId()
    }
    
    func removeAssetName() {
        assetNameView.removeName()
    }
    
    func removeAssetUnitName() {
        assetNameView.removeUnitName()
    }
    
    func setAssetNameAlignment(_ alignment: NSTextAlignment) {
        assetNameView.setAlignment(alignment)
    }
}

extension TransactionAccountInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 16.0
        let containerHorizontalInset: CGFloat = 20.0
        let containerTopInset: CGFloat = 8.0
        let titleLeadingInset: CGFloat = 24.0
        let buttonTrailingInset: CGFloat = 14.0
        let minimumOffset: CGFloat = 4.0
        let separatorHeight: CGFloat = 1.0
        let verticalInset: CGFloat = 12.0
        let imageVerticalOffset: CGFloat = 10.0
        let imageSize = CGSize(width: 20.0, height: 20.0)
        let buttonSize = CGSize(width: 40.0, height: 40.0)
    }
}

protocol TransactionAccountInformationViewDelegate: AnyObject {
    func transactionAccountInformationViewDidTapRemoveButton(_ transactionAccountInformationView: TransactionAccountInformationView)
}
