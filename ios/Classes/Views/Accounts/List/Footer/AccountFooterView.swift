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
//  AssetFooterView.swift

import UIKit

class AccountFooterView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountFooterViewDelegate?
    
    private lazy var containerView = UIView()
    
    private lazy var addAssetButton: AlignedButton = {
        let button = AlignedButton(.imageAtLeft(spacing: 4.0))
        button.setImage(img("icon-plus-primary"), for: .normal)
        button.setTitle("accounts-add-new".localized, for: .normal)
        button.setTitleColor(Colors.ButtonText.actionButton, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 14.0))
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        containerView.backgroundColor = Colors.Background.secondary
        containerView.layer.cornerRadius = 12.0
        containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupAddAssetButtonLayout()
    }
    
    override func setListeners() {
        addAssetButton.addTarget(self, action: #selector(notifyDelegateToAddAssetButtonTapped), for: .touchUpInside)
    }
}

extension AccountFooterView {
    @objc
    private func notifyDelegateToAddAssetButtonTapped() {
        delegate?.accountFooterViewDidTapAddAssetButton(self)
    }
}

extension AccountFooterView {
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.containerHeight)
        }
    }
    
    private func setupAddAssetButtonLayout() {
        containerView.addSubview(addAssetButton)
        
        addAssetButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension AccountFooterView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 12.0
        let containerHeight: CGFloat = 52.0
        let bottomInset: CGFloat = 16.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol AccountFooterViewDelegate: class {
    func accountFooterViewDidTapAddAssetButton(_ accountFooterView: AccountFooterView)
}
