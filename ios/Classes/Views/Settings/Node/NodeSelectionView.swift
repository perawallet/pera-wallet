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
//  NodeSelectionView.swift

import UIKit

class NodeSelectionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var backgroundImageView = UIImageView(image: img("bg-settings-node-unselected"))
    
    private lazy var imageView = UIImageView()
    
    private lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    override func prepareLayout() {
        setupBackgroundImageViewLayout()
        setupImageViewLayout()
        setupNameLabelLayout()
    }
}

extension NodeSelectionView {
    private func setupBackgroundImageViewLayout() {
        addSubview(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.nameOffset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension NodeSelectionView {
    func bind(_ viewModel: NodeSettingsViewModel) {
        backgroundImageView.image = viewModel.backgroundImage
        imageView.image = viewModel.image
        nameLabel.text = viewModel.nodeName
    }

    func setBackgroundImage(_ image: UIImage?) {
        backgroundImageView.image = image
    }

    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
}

extension NodeSelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let separatorHeight: CGFloat = 1.0
        let nameOffset: CGFloat = 12.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let horizontalInset: CGFloat = 20.0
    }
}
