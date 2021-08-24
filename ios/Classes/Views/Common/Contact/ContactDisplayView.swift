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
//  ContactDisplayView.swift

import UIKit

class ContactDisplayView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: ContactDisplayViewDelegate?
    
    private lazy var imageView = UIImageView()
    
    private(set) lazy var nameLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withLine(.contained)
            .withAlignment(.right)
            .withTextColor(Colors.Text.primary)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom).withBackgroundColor(Colors.Background.reversePrimary)
        button.layer.cornerRadius = 20.0
        return button
    }()
    
    override func configureAppearance() {
        imageView.layer.cornerRadius = layout.current.imageSize.width / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        backgroundColor = .clear
    }
    
    override func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDelegateToHandleAction), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupActionButtonLayout()
        setupNameLabelLayout()
        setupImageViewLayout()
    }
}

extension ContactDisplayView {
    @objc
    private func notifyDelegateToHandleAction() {
        delegate?.contactDisplayViewDidTapActionButton(self)
    }
}

extension ContactDisplayView {
    private func setupActionButtonLayout() {
        addSubview(actionButton)
        
        actionButton.snp.makeConstraints { make in
            make.size.equalTo(layout.current.buttonSize)
            make.trailing.equalToSuperview().inset(layout.current.buttonTrailingInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().priority(.low)
            make.trailing.equalTo(actionButton.snp.leading).offset(layout.current.nameLabelOffset)
            make.top.bottom.equalToSuperview().inset(layout.current.veritcalInset)
            make.leading.equalToSuperview().priority(.low)
        }
    }
    
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(nameLabel)
            make.trailing.equalTo(nameLabel.snp.leading).offset(layout.current.imageOffset)
            make.size.equalTo(layout.current.imageSize)
        }
    }
}

extension ContactDisplayView {
    func setContact(_ contact: Contact) {
        if let imageData = contact.image,
            let image = UIImage(data: imageData) {
            let resizedImage = image.convert(to: CGSize(width: 24.0, height: 24.0))
            imageView.image = resizedImage
        }
        
        nameLabel.text = contact.name
    }
    
    func setButtonImage(_ image: UIImage?) {
        actionButton.setImage(image, for: .normal)
    }
    
    func removeAction() {
        actionButton.removeFromSuperview()
    }
    
    func setName(_ name: String) {
        nameLabel.text = name
    }
    
    func setImage(hidden: Bool) {
        imageView.isHidden = hidden
    }
    
    func removeImage() {
        imageView.removeFromSuperview()
    }
}

extension ContactDisplayView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let veritcalInset: CGFloat = 10.0
        let nameLabelOffset: CGFloat = -12.0
        let imageOffset: CGFloat = -8.0
        let buttonTrailingInset: CGFloat = 8.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol ContactDisplayViewDelegate: AnyObject {
    func contactDisplayViewDidTapActionButton(_ contactDisplayView: ContactDisplayView)
}
