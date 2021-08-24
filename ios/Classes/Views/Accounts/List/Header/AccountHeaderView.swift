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
//  AssetHeaderView.swift

import UIKit

class AccountHeaderView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountHeaderViewDelegate?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8.0
        view.backgroundColor = Colors.Component.accountHeader
        return view
    }()
    
    private lazy var imageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        UILabel().withAlignment(.left).withFont(UIFont.font(withWeight: .medium(size: 14.0))).withTextColor(Colors.Text.primary)
    }()
    
    private(set) lazy var qrButton: UIButton = {
        UIButton(type: .custom).withImage(img("icon-qr"))
    }()
    
    private lazy var optionsButton: UIButton = {
        UIButton(type: .custom).withImage(img("icon-options"))
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        layer.cornerRadius = 12.0
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupImageViewLayout()
        setupOptionsButtonLayout()
        setupQRButtonLayout()
        setupTitleLabelLayout()
    }
    
    override func setListeners() {
        qrButton.addTarget(self, action: #selector(notifyDelegateToOpenQRScanning), for: .touchUpInside)
        optionsButton.addTarget(self, action: #selector(notifyDelegateToOpenAccountOptions), for: .touchUpInside)
    }
}

extension AccountHeaderView {
    @objc
    private func notifyDelegateToOpenQRScanning() {
        delegate?.accountHeaderViewDidTapQRButton(self)
    }
    
    @objc
    private func notifyDelegateToOpenAccountOptions() {
        delegate?.accountHeaderViewDidTapOptionsButton(self)
    }
}

extension AccountHeaderView {
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(layout.current.containerInset)
        }
    }
    
    private func setupImageViewLayout() {
        imageView.contentMode = .scaleAspectFit
        
        containerView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.imageSize)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupOptionsButtonLayout() {
        containerView.addSubview(optionsButton)
        
        optionsButton.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.trailing.equalToSuperview().inset(layout.current.trailingInset)
            make.size.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupQRButtonLayout() {
        containerView.addSubview(qrButton)
        
        qrButton.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.trailing.equalTo(optionsButton.snp.leading).offset(-layout.current.buttonOffset)
            make.size.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupTitleLabelLayout() {
        containerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.labelInset)
            make.centerY.equalTo(imageView)
            make.trailing.lessThanOrEqualTo(qrButton.snp.leading).offset(-layout.current.labelInset)
        }
    }
}

extension AccountHeaderView {
    func bind(_ viewModel: AccountHeaderSupplementaryViewModel) {
        titleLabel.text = viewModel.accountName
        imageView.image = viewModel.accountImage
        optionsButton.isHidden = !viewModel.isActionEnabled
        qrButton.isHidden = !viewModel.isActionEnabled
    }
}

extension AccountHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 16.0
        let containerInset: CGFloat = 4.0
        let labelInset: CGFloat = 12.0
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let verticalInset: CGFloat = 12.0
        let buttonOffset: CGFloat = 2.0
        let trailingInset: CGFloat = 8.0
    }
}

protocol AccountHeaderViewDelegate: AnyObject {
    func accountHeaderViewDidTapQRButton(_ accountHeaderView: AccountHeaderView)
    func accountHeaderViewDidTapOptionsButton(_ accountHeaderView: AccountHeaderView)
}
