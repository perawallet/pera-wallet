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
//  ContactAssetView.swift

import UIKit

class ContactAssetView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: ContactAssetViewDelegate?
    
    private lazy var backgroundImageView = UIImageView(image: img("bg-asset-contact-cell"))
    
    private(set) lazy var assetNameView = AssetNameView()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .custom)
            .withBackgroundImage(img("bg-send-small"))
            .withImage(img("icon-arrow-up-24"))
            .withAlignment(.center)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
        sendButton.addTarget(self, action: #selector(notifyDelegateToSendButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupSendButtonLayout()
        setupAssetNameViewLayout()
    }
}

extension ContactAssetView {
    @objc
    private func notifyDelegateToSendButtonTapped() {
        delegate?.contactAssetViewDidTapSendButton(self)
    }
}

extension ContactAssetView {
    private func setupSendButtonLayout() {
        addSubview(sendButton)
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupAssetNameViewLayout() {
        addSubview(assetNameView)
        
        assetNameView.setContentCompressionResistancePriority(.required, for: .horizontal)
        assetNameView.setContentHuggingPriority(.required, for: .horizontal)
        
        assetNameView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(sendButton.snp.leading).offset(-layout.current.mininmumOffset)
        }
    }
}

extension ContactAssetView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 16.0
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let mininmumOffset: CGFloat = 4.0
    }
}

protocol ContactAssetViewDelegate: class {
    func contactAssetViewDidTapSendButton(_ contactAssetView: ContactAssetView)
}
