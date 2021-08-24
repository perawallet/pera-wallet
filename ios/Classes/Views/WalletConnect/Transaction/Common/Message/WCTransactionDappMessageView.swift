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
//   WCTransactionDappMessageView.swift

import UIKit
import Macaroon

class WCTransactionDappMessageView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCTransactionDappMessageViewDelegate?

    private lazy var dappImageView: URLImageView = {
        let imageView = URLImageView()
        imageView.layer.cornerRadius = 22.0
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = Colors.Component.dappImageBorderColor.cgColor
        return imageView
    }()

    private lazy var stackView: VStackView = {
        let stackView = VStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.spacing = layout.current.spacing
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.isUserInteractionEnabled = false
        return stackView
    }()

    private lazy var nameLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(Colors.Text.primary)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
    }()

    private lazy var messageLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(Colors.Text.secondary)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()

    private lazy var readMoreLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(Colors.Text.link)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withText("wallet-connect-transaction-dapp-show-more".localized)
    }()

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        layer.cornerRadius = 12.0
    }

    override func prepareLayout() {
        setupDappImageViewLayout()
        setupStackViewLayout()
    }
}

extension WCTransactionDappMessageView {
    private func setupDappImageViewLayout() {
        addSubview(dappImageView)

        dappImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview().inset(layout.current.defaultInset)
        }
    }

    private func setupStackViewLayout() {
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.leading.equalTo(dappImageView.snp.trailing).offset(layout.current.nameLabelLeadingInset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.centerY.equalToSuperview()
        }

        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(readMoreLabel)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if frame.contains(point) {
            delegate?.wcTransactionDappMessageViewDidTapped(self)
            return super.hitTest(point, with: event)
        }

        return nil
    }
}

extension WCTransactionDappMessageView {
    func bind(_ viewModel: WCTransactionDappMessageViewModel) {
        dappImageView.load(from: viewModel.image)
        nameLabel.text = viewModel.name
        messageLabel.text = viewModel.message
        readMoreLabel.isHidden = viewModel.isReadMoreHidden
    }
}

extension WCTransactionDappMessageView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let nameLabelLeadingInset: CGFloat = 16.0
        let spacing: CGFloat = 4.0
        let messageLabelVerticalInset: CGFloat = 4.0
        let imageSize = CGSize(width: 44.0, height: 44.0)
    }
}

protocol WCTransactionDappMessageViewDelegate: AnyObject {
    func wcTransactionDappMessageViewDidTapped(_ WCTransactionDappMessageView: WCTransactionDappMessageView)
}
