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
//  NoInternetConnectionView.swift

import UIKit

class NoInternetConnectionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView(image: img("icon-no-internet-connection"))
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Text.primary)
            .withAlignment(.center)
            .withText("internet-connection-error-title".localized)
            .withLine(.single)
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.tertiary)
            .withAlignment(.center)
            .withText("internet-connection-error-detail".localized)
            .withLine(.contained)
    }()
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
    }
}

extension NoInternetConnectionView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.subtitleHorizontalInset)
        }
    }
}

extension NoInternetConnectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 24.0
        let subtitleTopInset: CGFloat = 12.0
        let subtitleHorizontalInset: CGFloat = 40.0
    }
}
