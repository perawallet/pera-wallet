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
//  TransactionErrorView.swift

import UIKit

class ListErrorView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: ListErrorViewDelegate?
    
    private lazy var imageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.tertiary)
            .withLine(.contained)
    }()
    
    private lazy var tryAgainButton: AlignedButton = {
        let button = AlignedButton(.imageAtLeft(spacing: 8.0))
        button.setBackgroundImage(img("bg-try-again"), for: .normal)
        button.setImage(img("icon-reload"), for: .normal)
        button.setTitle("transaction-filter-try-again".localized, for: .normal)
        button.setTitleColor(Colors.ButtonText.secondary, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 16.0))
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.7
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func setListeners() {
        tryAgainButton.addTarget(self, action: #selector(notifyDelegateToTryAgain), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
        setupTryAgainButtonLayout()
    }
}

extension ListErrorView {
    @objc
    private func notifyDelegateToTryAgain() {
        delegate?.listErrorViewDidTryAgain(self)
    }
}

extension ListErrorView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.titleTopInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview().inset(layout.current.titleHorizontalInset)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview().inset(layout.current.subtitleHorizontalInset)
        }
    }
    
    private func setupTryAgainButtonLayout() {
        addSubview(tryAgainButton)
        
        tryAgainButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.buttonTopInset)
            make.centerX.equalToSuperview()
            make.size.equalTo(layout.current.buttonSize)
        }
    }
}

extension ListErrorView {
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setSubtitle(_ subtitle: String) {
        subtitleLabel.text = subtitle
    }
}

extension ListErrorView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 100.0
        let imageSize = CGSize(width: 48.0, height: 48.0)
        let titleTopInset: CGFloat = 16.0
        let titleHorizontalInset: CGFloat = 20.0
        let subtitleHorizontalInset: CGFloat = 40.0
        let subtitleTopInset: CGFloat = 8.0
        let buttonTopInset: CGFloat = 24.0
        let buttonSize = CGSize(width: 153.0, height: 44.0)
    }
}

protocol ListErrorViewDelegate: class {
    func listErrorViewDidTryAgain(_ listErrorView: ListErrorView)
}
