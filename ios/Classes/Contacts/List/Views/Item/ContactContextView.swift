// Copyright 2022 Pera Wallet, LDA

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
import MacaroonUIKit

final class ContactContextView: View {
    weak var delegate: ContactContextViewDelegate?

    private(set) lazy var userImageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var addressLabel = UILabel()
    private(set) lazy var qrDisplayButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setListeners()
    }

    func customize(_ theme: ContactContextViewTheme) {
        addUserImageView(theme)
        addNameLabel(theme)
        addAddressLabel(theme)
        addQRDisplayButton(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func setListeners() {
        qrDisplayButton.addTarget(self, action: #selector(notifyDelegateToQRDisplayButtonTapped), for: .touchUpInside)
    }
}

extension ContactContextView {
    @objc
    private func notifyDelegateToQRDisplayButtonTapped() {
        delegate?.contactContextViewDidTapQRDisplayButton(self)
    }
}

extension ContactContextView {
    private func addUserImageView(_ theme: ContactContextViewTheme) {
        userImageView.customizeAppearance(theme.userImage)
        userImageView.layer.cornerRadius = theme.userImageCorner.radius
        userImageView.clipsToBounds = true

        addSubview(userImageView)
        userImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.fitToSize(theme.imageSize)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func addNameLabel(_ theme: ContactContextViewTheme) {
        nameLabel.customizeAppearance(theme.nameLabel)

        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.verticalPadding)
            $0.leading.equalTo(userImageView.snp.trailing).offset(theme.labelHorizontalPaddings.leading)
            $0.trailing.equalToSuperview().inset(theme.labelHorizontalPaddings.trailing)
        }
    }
    
    private func addAddressLabel(_ theme: ContactContextViewTheme) {
        addressLabel.customizeAppearance(theme.addressLabel)

        addSubview(addressLabel)
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(theme.addressLabelTopPadding)
            $0.bottom.equalToSuperview().inset(theme.verticalPadding)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalToSuperview().offset(theme.labelHorizontalPaddings.trailing)
        }
    }
    
    private func addQRDisplayButton(_ theme: ContactContextViewTheme) {
        qrDisplayButton.customizeAppearance(theme.qrButton)

        addSubview(qrDisplayButton)
        qrDisplayButton.snp.makeConstraints {
            $0.fitToSize(theme.buttonSize)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.centerY.equalTo(userImageView)
        }
    }
}

extension ContactContextView: ViewModelBindable {
    func bindData(_ viewModel: ContactsViewModel?) {
        userImageView.image = viewModel?.image
        nameLabel.editText = viewModel?.name
        addressLabel.text = viewModel?.address
    }
}

protocol ContactContextViewDelegate: AnyObject {
    func contactContextViewDidTapQRDisplayButton(_ contactContextView: ContactContextView)
}
