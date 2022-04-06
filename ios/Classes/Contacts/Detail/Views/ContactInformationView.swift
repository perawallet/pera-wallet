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
//   ContactInformationView.swift

import MacaroonUIKit
import UIKit

final class ContactInformationView: View {
    weak var delegate: ContactInformationViewDelegate?

    private lazy var imageView = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var accountShortAddressLabel = UILabel()
    private lazy var topDivider = UIView()
    private lazy var accountAddressTitleLabel = UILabel()
    private lazy var accountAddressValueLabel = UILabel()
    private lazy var qrCodeButton = MacaroonUIKit.Button()
    private lazy var bottomDivider = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setListeners()
    }

    func customize(_ theme: ContactInformationViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addImageView(theme)
        addNameLabelView(theme)
        addAccountShortAddressLabel(theme)
        addTopDivider(theme)
        addAccountAddressTitleLabel(theme)
        addAccountAddressValueLabel(theme)
        addQrCodeButton(theme)
        addBottomDivider(theme)
    }
    
    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func setListeners() {
        qrCodeButton.addTarget(self, action: #selector(didTapQRButton), for: .touchUpInside)
    }
}

extension ContactInformationView {
    @objc
    private func didTapQRButton() {
        delegate?.contactInformationViewDidTapQRButton(self)
    }
}

extension ContactInformationView {
    private func addImageView(_ theme: ContactInformationViewTheme) {
        imageView.layer.draw(corner: theme.imageViewCorner)
        imageView.clipsToBounds = true

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.fitToSize(theme.imageViewSize)
            $0.top.centerX.equalToSuperview()
        }
    }

    private func addNameLabelView(_ theme: ContactInformationViewTheme) {
        nameLabel.customizeAppearance(theme.nameLabel)

        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(theme.nameLabelTopPadding)
            $0.leading.trailing.lessThanOrEqualToSuperview().inset(theme.horizontalPadding)
            $0.centerX.equalToSuperview()
        }
    }

    private func addAccountShortAddressLabel(_ theme: ContactInformationViewTheme) {
        accountShortAddressLabel.customizeAppearance(theme.accountShortAddressLabel)

        addSubview(accountShortAddressLabel)
        accountShortAddressLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(theme.shortAccountAddressLabelTopPadding)
            $0.centerX.equalToSuperview()
        }
    }

    private func addTopDivider(_ theme: ContactInformationViewTheme) {
        topDivider.customizeAppearance(theme.divider)

        addSubview(topDivider)
        topDivider.snp.makeConstraints {
            $0.fitToHeight(theme.dividerHeight)
            $0.top.equalTo(accountShortAddressLabel.snp.bottom).offset(theme.dividerVerticalPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addAccountAddressTitleLabel(_ theme: ContactInformationViewTheme) {
        accountAddressTitleLabel.customizeAppearance(theme.accountAddressTitleLabel)

        addSubview(accountAddressTitleLabel)
        accountAddressTitleLabel.snp.makeConstraints {
            $0.top.equalTo(topDivider.snp.bottom).offset(theme.dividerVerticalPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addAccountAddressValueLabel(_ theme: ContactInformationViewTheme) {
        accountAddressValueLabel.customizeAppearance(theme.accountAddressValueLabel)

        addSubview(accountAddressValueLabel)
        accountAddressValueLabel.snp.makeConstraints {
            $0.top.equalTo(accountAddressTitleLabel.snp.bottom).offset(theme.accountAddressValueLabelPaddings.top)
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.trailing.equalToSuperview().inset(theme.accountAddressValueLabelPaddings.trailing)
        }
    }

    private func addQrCodeButton(_ theme: ContactInformationViewTheme) {
        qrCodeButton.customizeAppearance(theme.qrCode)

        addSubview(qrCodeButton)
        qrCodeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(topDivider.snp.bottom).offset(theme.qrButtonTopPadding)
        }
    }

    private func addBottomDivider(_ theme: ContactInformationViewTheme) {
        bottomDivider.customizeAppearance(theme.divider)

        addSubview(bottomDivider)
        bottomDivider.snp.makeConstraints {
            $0.fitToHeight(theme.dividerHeight)
            $0.bottom.equalToSuperview()
            $0.top.equalTo(accountAddressValueLabel.snp.bottom).offset(theme.dividerVerticalPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
}

extension ContactInformationView: ViewModelBindable {
    func bindData(_ viewModel: ContactInformationViewModel?) {
        imageView.image = viewModel?.image
        nameLabel.text = viewModel?.name
        accountAddressValueLabel.text = viewModel?.address
        accountShortAddressLabel.text = viewModel?.shortAddress
    }
}

protocol ContactInformationViewDelegate: AnyObject {
    func contactInformationViewDidTapQRButton(_ view: ContactInformationView)
}
