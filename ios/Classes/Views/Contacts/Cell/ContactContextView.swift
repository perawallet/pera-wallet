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
//  ContactContextView.swift

import UIKit

class ContactContextView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var userImageView: UIImageView = {
        let imageView = UIImageView(image: img("icon-user-placeholder"))
        imageView.backgroundColor = Colors.Background.reversePrimary
        imageView.layer.cornerRadius = layout.current.imageSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.primary)
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()
    
    private lazy var addressLabel: UILabel = {
        UILabel()
            .withTextColor(Colors.Text.secondary)
            .withAlignment(.left)
            .withLine(.single)
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
    }()
    
    private(set) lazy var qrDisplayButton: UIButton = {
        let button = UIButton(type: .custom)
            .withImage(img("icon-qr", isTemplate: true))
            .withBackgroundColor(Colors.Background.reversePrimary)
        button.layer.cornerRadius = 20.0
        button.tintColor = Colors.Text.secondary
        return button
    }()
    
    weak var delegate: ContactContextViewDelegate?
    
    override func setListeners() {
        qrDisplayButton.addTarget(self, action: #selector(notifyDelegateToQRDisplayButtonTapped), for: .touchUpInside)
    }
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func prepareLayout() {
        setupUserImageViewLayout()
        setupNameLabelLayout()
        setupAddressLabelLayout()
        setupQRDisplayButtonLayout()
    }
}

extension ContactContextView {
    @objc
    private func notifyDelegateToQRDisplayButtonTapped() {
        delegate?.contactContextViewDidTapQRDisplayButton(self)
    }
}

extension ContactContextView {
    private func setupUserImageViewLayout() {
        addSubview(userImageView)
        
        userImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.width.height.equalTo(layout.current.imageSize)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupNameLabelLayout() {
        addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(userImageView.snp.centerY).inset(-layout.current.minimumOffset)
            make.leading.equalTo(userImageView.snp.trailing).offset(layout.current.labelLeftInset)
        }
    }
    
    private func setupAddressLabelLayout() {
        addSubview(addressLabel)
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.centerY).offset(layout.current.minimumOffset)
            make.leading.equalTo(nameLabel)
        }
    }
    
    private func setupQRDisplayButtonLayout() {
        addSubview(qrDisplayButton)
        
        qrDisplayButton.snp.makeConstraints { make in
            make.width.height.equalTo(layout.current.buttonSize)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(userImageView)
            make.leading.greaterThanOrEqualTo(addressLabel.snp.trailing).offset(layout.current.minimumOffset)
        }
    }
}

extension ContactContextView {
    func bind(_ viewModel: ContactsViewModel) {
        userImageView.image = viewModel.image
        nameLabel.text = viewModel.name
        addressLabel.text = viewModel.address
    }
}

extension ContactContextView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 10.0
        let imageSize: CGFloat = 44.0
        let buttonSize: CGFloat = 40.0
        let labelLeftInset: CGFloat = 12.0
        let minimumOffset: CGFloat = 4.0
    }
}

protocol ContactContextViewDelegate: AnyObject {
    func contactContextViewDidTapQRDisplayButton(_ contactContextView: ContactContextView)
}
