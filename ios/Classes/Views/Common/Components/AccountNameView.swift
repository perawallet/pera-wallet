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
//  AccountNameView.swift

import UIKit

class AccountNameView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView()
    
    private lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupNameLabelLayout()
    }
}

extension AccountNameView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.top.bottom.equalToSuperview()
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
}

extension AccountNameView {
    func setAccountImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setAccountName(_ name: String?) {
        nameLabel.text = name
    }
    
    func bind(_ viewModel: AccountNameViewModel) {
        imageView.image = viewModel.image
        nameLabel.text = viewModel.name
    }
    
    func bind(_ viewModel: AuthAccountNameViewModel) {
        imageView.image = viewModel.image
        nameLabel.text = viewModel.address
    }
}

extension AccountNameView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 12.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
    }
}
