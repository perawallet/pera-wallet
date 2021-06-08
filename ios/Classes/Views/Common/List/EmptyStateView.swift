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
//  AccountsEmptyStateView.swift

import UIKit

class EmptyStateView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView(image: image)
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(Colors.Text.primary)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withText(title)
    }()
    
    private(set) lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAttributedText(subtitle.attributed([.lineSpacing(1.2)]))
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(Colors.Text.tertiary)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()
    
    private var image: UIImage?
    private var title: String = ""
    private var subtitle: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(image: UIImage?, title: String, subtitle: String) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
    }
}

extension EmptyStateView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().inset(layout.current.imageCenterOffset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.titleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension EmptyStateView {
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

extension EmptyStateView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 40.0 * horizontalScale
        let imageCenterOffset: CGFloat = 60.0
        let titleTopInset: CGFloat = 24.0 * verticalScale
        let subtitleTopInset: CGFloat = 12.0 * verticalScale
    }
}
