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
//  NodeSettingsHeaderView.swift

import UIKit

class NodeSettingsHeaderView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView(image: img("icon-settings-node"))
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withAttributedText("node-settings-subtitle".localized.attributed([.lineSpacing(1.2)]))
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.center)
            .withLine(.contained)
    }()
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupTitleLabelLayout()
    }
}

extension NodeSettingsHeaderView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.imageTopInset)
            make.centerX.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.titleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension NodeSettingsHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageTopInset: CGFloat = 50.0
        let imageSize = CGSize(width: 48.0, height: 48.0)
        let titleTopInset: CGFloat = 16.0
        let horizontalInset: CGFloat = 32.0
        let topInset: CGFloat = 26.0
    }
}
