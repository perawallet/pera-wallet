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
//  TransactionReceiverButton.swift

import UIKit

class TransactionReceiverButton: BaseControl {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var containerView = UIView()
    
    private lazy var imageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    init(title: String, image: UIImage?) {
        super.init()
        titleLabel.text = title
        imageView.image = image
    }

    override func configureAppearance() {
        containerView.backgroundColor = Colors.Background.secondary
        containerView.isUserInteractionEnabled = false
        containerView.layer.cornerRadius = 12.0
        containerView.applySmallShadow()
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupImageViewLayout()
        setupTitleLabelLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.updateShadowLayoutWhenViewDidLayoutSubviews()
    }
    
    @available(iOS 12.0, *)
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        if userInterfaceStyle == .dark {
            containerView.removeShadows()
        } else {
            containerView.applySmallShadow()
        }
    }
}

extension TransactionReceiverButton {
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(containerView.snp.height).multipliedBy(1.05)
        }
    }
    
    private func setupImageViewLayout() {
        containerView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.centerY.equalToSuperview().offset(layout.current.imageViewCenterOffset)
        }
    }
    
    private func setupTitleLabelLayout() {
        containerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.titleOffset)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}

extension TransactionReceiverButton {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleOffset: CGFloat = 8.0
        let imageViewCenterOffset: CGFloat = -12.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
    }
}
