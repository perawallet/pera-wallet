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
//  AccountFooterSupplementaryView.swift

import UIKit

class AccountFooterSupplementaryView: BaseSupplementaryView<AccountFooterView> {
    
    weak var delegate: AccountFooterSupplementaryViewDelegate?
    
    override func setListeners() {
        contextView.delegate = self
    }
}

extension AccountFooterSupplementaryView: AccountFooterViewDelegate {
    func accountFooterViewDidTapAddAssetButton(_ accountFooterView: AccountFooterView) {
        delegate?.accountFooterSupplementaryViewDidTapAddAssetButton(self)
    }
}

protocol AccountFooterSupplementaryViewDelegate: AnyObject {
    func accountFooterSupplementaryViewDidTapAddAssetButton(_ accountFooterSupplementaryView: AccountFooterSupplementaryView)
}

class EmptyFooterSupplementaryView: BaseSupplementaryView<EmptyFooterView> {

    override func configureAppearance() {
        backgroundColor = .clear
        layer.cornerRadius = 12.0
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}

class EmptyFooterView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var containerView = UIView()

    override func configureAppearance() {
        backgroundColor = .clear
        containerView.backgroundColor = Colors.Background.secondary
        containerView.layer.cornerRadius = 12.0
        containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupContainerViewLayout()
    }

    private func setupContainerViewLayout() {
        addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.height)
        }
    }
}

extension EmptyFooterView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let height: CGFloat = 24.0
    }
}
