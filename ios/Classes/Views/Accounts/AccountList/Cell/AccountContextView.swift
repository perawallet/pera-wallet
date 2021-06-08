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
//  AccountView.swift

import UIKit

class AccountContextView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var accountTypeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-algo-black"))
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.right)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupDetailLabelLayout()
        setupImageViewLayout()
        setupAccountTypeImageViewLayout()
        setupNameLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension AccountContextView {
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
        }
    }
    
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(detailLabel.snp.leading).offset(layout.current.imageViewOffset)
        }
    }
    
    private func setupAccountTypeImageViewLayout() {
        addSubview(accountTypeImageView)
        
        accountTypeImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(accountTypeImageView.snp.trailing).offset(layout.current.nameLabelInset).priority(.required)
            make.leading.equalToSuperview().inset(layout.current.defaultInset).priority(.medium)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(imageView.snp.leading)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.height.equalTo(layout.current.separatorHeight)
            make.bottom.equalToSuperview()
        }
    }
}

extension AccountContextView {
    func bind(_ viewModel: AccountListViewModel) {
        nameLabel.text = viewModel.name

        if let accountImage = viewModel.accountImage {
            accountTypeImageView.isHidden = false
            accountTypeImageView.image = accountImage
        } else {
            accountTypeImageView.removeFromSuperview()
        }

        if let detailText = viewModel.detail {
            detailLabel.text = detailText
        } else if let detailAttributedText = viewModel.attributedDetail {
            detailLabel.attributedText = detailAttributedText
        }

        if let detailColor = viewModel.detailColor {
            detailLabel.textColor = detailColor
        }

        imageView.isHidden = !viewModel.isDisplayingImage
    }
}

extension AccountContextView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let imageViewOffset: CGFloat = -2.0
        let separatorHeight: CGFloat = 1.0
        let nameLabelInset: CGFloat = 12.0
    }
}
