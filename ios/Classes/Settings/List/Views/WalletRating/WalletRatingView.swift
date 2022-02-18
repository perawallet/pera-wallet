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
//   WalletRatingModalView.swift

import MacaroonUIKit
import UIKit

final class WalletRatingView: View {
    weak var delegate: WalletRatingViewDelegate?
    
    private lazy var theme = WalletRatingViewTheme()
    private lazy var likeButton = UIButton()
    private lazy var dislikeButton = UIButton()
    private lazy var titleLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customize(theme)
    }
    
    func customize(_ theme: WalletRatingViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addLikeButton()
        addDislikeButton()
        addTitleLabel()
        addDescriptionLabel()
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func setListeners() {
        likeButton.addTarget(self, action: #selector(notifyDelegateToRateWallet), for: .touchUpInside)
        dislikeButton.addTarget(self, action: #selector(notifyDelegateToRateWallet), for: .touchUpInside)
    }
}

extension WalletRatingView {
    @objc
    private func notifyDelegateToRateWallet() {
        delegate?.walletRatingViewDidTapButton(self)
    }
}

extension WalletRatingView {
    private func addLikeButton() {
        likeButton.customizeAppearance(theme.likeButton)
        
        addSubview(likeButton)
        likeButton.snp.makeConstraints {
            $0.trailing == snp.centerX - theme.horizontalInset
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }
    
    private func addDislikeButton() {
        dislikeButton.customizeAppearance(theme.dislikeButton)
        
        addSubview(dislikeButton)
        dislikeButton.snp.makeConstraints {
            $0.leading == snp.centerX + theme.horizontalInset
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }
    
    private func addTitleLabel() {
        titleLabel.customizeAppearance(theme.title)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(dislikeButton.snp.bottom).offset(theme.titleTopInset)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func addDescriptionLabel() {
        descriptionLabel.customizeAppearance(theme.description)
        
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.descriptionTopInset)
            $0.centerX.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + theme.bottomInset)
        }
    }
}

protocol WalletRatingViewDelegate: AnyObject {
    func walletRatingViewDidTapButton(_ walletRatingView: WalletRatingView)
}
