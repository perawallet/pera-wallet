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
//   WCTransactionFullDappDetailView.swift

import UIKit
import Macaroon

class WCTransactionFullDappDetailView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCTransactionFullDappDetailViewDelegate?

    private lazy var dappImageView: URLImageView = {
        let imageView = URLImageView()
        imageView.layer.cornerRadius = 30.0
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = Colors.Component.dappImageBorderColor.cgColor
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(Colors.Text.primary)
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
    }()

    private lazy var messageLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(Colors.Text.primary)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()

    private lazy var closeButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withTitle("title-close".localized)
            .withTitleColor(Colors.ButtonText.secondary)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }

    override func prepareLayout() {
        setupDappImageViewLayout()
        setupNameLabelLayout()
        setupMessageLabelLayout()
        setupCloseButtonLayout()
    }

    override func setListeners() {
        closeButton.addTarget(self, action: #selector(notifyDelegateToCloseScreen), for: .touchUpInside)
    }
}

extension WCTransactionFullDappDetailView {
    private func setupDappImageViewLayout() {
        addSubview(dappImageView)

        dappImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupNameLabelLayout() {
        addSubview(nameLabel)

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(dappImageView.snp.bottom).offset(layout.current.nameTopInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupMessageLabelLayout() {
        addSubview(messageLabel)

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(layout.current.messageLabelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupCloseButtonLayout() {
        addSubview(closeButton)

        closeButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(messageLabel.snp.bottom).offset(layout.current.buttonTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.bottomInset)
        }
    }
}

extension WCTransactionFullDappDetailView {
    @objc
    private func notifyDelegateToCloseScreen() {
        delegate?.wcTransactionFullDappDetailViewDidCloseScreen(self)
    }
}

extension WCTransactionFullDappDetailView {
    func bind(_ viewModel: WCTransactionDappMessageViewModel) {
        dappImageView.load(from: viewModel.image)
        nameLabel.text = viewModel.name
        messageLabel.text = viewModel.message
    }
}

extension WCTransactionFullDappDetailView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageSize = CGSize(width: 60.0, height: 60.0)
        let bottomInset: CGFloat = 16.0
        let horizontalInset: CGFloat = 20.0
        let topInset: CGFloat = 28.0
        let nameTopInset: CGFloat = 16.0
        let messageLabelTopInset: CGFloat = 20.0
        let buttonTopInset: CGFloat = 24.0
    }
}

protocol WCTransactionFullDappDetailViewDelegate: AnyObject {
    func wcTransactionFullDappDetailViewDidCloseScreen(_ wcTransactionFullDappDetailView: WCTransactionFullDappDetailView)
}
