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
//  SelectAssetHeaderView.swift

import UIKit

class SelectAssetHeaderView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        UILabel().withAlignment(.left).withFont(UIFont.font(withWeight: .medium(size: 14.0))).withTextColor(Colors.Text.primary)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Component.assetHeader
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupTitleLabelLayout()
    }
}

extension SelectAssetHeaderView {
    private func setupImageViewLayout() {
        imageView.contentMode = .scaleAspectFit
        
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.imageSize)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.labelInset)
            make.centerY.equalTo(imageView)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension SelectAssetHeaderView {
    func bind(_ viewModel: SelectAssetViewModel) {
        titleLabel.text = viewModel.accountName
        imageView.image = viewModel.accountImage
    }
}

extension SelectAssetHeaderView {
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
