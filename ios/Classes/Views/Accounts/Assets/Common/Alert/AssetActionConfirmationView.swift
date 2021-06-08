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
//  AssetActionConfirmationView.swift

import UIKit

class AssetActionConfirmationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetActionConfirmationViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    private(set) lazy var assetDisplayView = AssetDisplayView()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var actionButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-main-button"))
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTitleColor(Colors.ButtonText.primary)
    }()
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-cancel".localized)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTitleColor(Colors.Text.primary)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDelegateToHandleAction), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCancelScreen), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupAssetDisplayViewLayout()
        setupDetailLabelLayout()
        setupActionButtonLayout()
        setupCancelButtonLayout()
    }
}

extension AssetActionConfirmationView {
    @objc
    private func notifyDelegateToHandleAction() {
        delegate?.assetActionConfirmationViewDidTapActionButton(self)
    }
    
    @objc
    private func notifyDelegateToCancelScreen() {
        delegate?.assetActionConfirmationViewDidTapCancelButton(self)
    }
}

extension AssetActionConfirmationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }

    private func setupAssetDisplayViewLayout() {
        addSubview(assetDisplayView)
        
        assetDisplayView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.displayViewTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.displayViewHorizontalInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(assetDisplayView.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(layout.current.displayViewTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(actionButton.snp.bottom).offset(layout.current.buttonOffset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension AssetActionConfirmationView {
    func bind(_ viewModel: AssetActionConfirmationViewModel) {
        titleLabel.text = viewModel.title
        assetDisplayView.assetIndexLabel.text = viewModel.id
        detailLabel.attributedText = viewModel.detail
        actionButton.setTitle(viewModel.actionTitle, for: .normal)
        if let assetDisplayViewModel = viewModel.assetDisplayViewModel {
            assetDisplayView.bind(assetDisplayViewModel)
        }
    }
}

extension AssetActionConfirmationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 16.0
        let displayViewHorizontalInset: CGFloat = 32.0
        let displayViewTopInset: CGFloat = 28.0
        let horizontalInset: CGFloat = 20.0
        let buttonOffset: CGFloat = 12.0
        let bottomInset: CGFloat = 30.0
    }
}

protocol AssetActionConfirmationViewDelegate: class {
    func assetActionConfirmationViewDidTapActionButton(_ assetActionConfirmationView: AssetActionConfirmationView)
    func assetActionConfirmationViewDidTapCancelButton(_ assetActionConfirmationView: AssetActionConfirmationView)
}
