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
//  RekeyConfirmationFooterView.swift

import UIKit

class RekeyConfirmationFooterView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: RekeyConfirmationFooterViewDelegate?
    
    private lazy var showMoreButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(Colors.Text.secondary)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupShowMoreButtonLayout()
    }
    
    override func setListeners() {
        showMoreButton.addTarget(self, action: #selector(notifyDelegateToShowMoreAssets), for: .touchUpInside)
    }
}

extension RekeyConfirmationFooterView {
    @objc
    private func notifyDelegateToShowMoreAssets() {
        delegate?.rekeyConfirmationFooterViewDidShowMoreAssets(self)
    }
}

extension RekeyConfirmationFooterView {
    private func setupShowMoreButtonLayout() {
        addSubview(showMoreButton)
        
        showMoreButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension RekeyConfirmationFooterView {
    func setMoreAssetsButtonTitle(_ title: String?) {
        showMoreButton.setTitle(title, for: .normal)
    }
}

extension RekeyConfirmationFooterView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 4.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol RekeyConfirmationFooterViewDelegate: AnyObject {
    func rekeyConfirmationFooterViewDidShowMoreAssets(_ rekeyConfirmationFooterView: RekeyConfirmationFooterView)
}
