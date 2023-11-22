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
//   WCTransactionDappMessageView.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class WCTransactionDappMessageView: BaseView {
    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCTransactionDappMessageViewDelegate?

    private lazy var dappImageView: URLImageView = {
        let imageView = URLImageView()
        imageView.layer.cornerRadius = layout.current.imageSize.width / 2
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

    private lazy var subtitleStackView: HStackView = {
        let stackView = HStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.spacing = layout.current.spacing
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.isUserInteractionEnabled = false
        return stackView
    }()

    private lazy var subtitleContainerView = UIView()

    private lazy var nameLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(Colors.Text.white.uiColor)
            .withFont(Fonts.DMSans.medium.make(19).uiFont)
    }()

    private lazy var messageLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(Colors.Other.Global.gray400.uiColor)
            .withFont(Fonts.DMSans.regular.make(13).uiFont)
    }()

    private lazy var readMoreLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(Colors.Helpers.positive.uiColor)
            .withFont(Fonts.DMSans.medium.make(13).uiFont)
            .withText("wallet-connect-transaction-dapp-show-more".localized)
    }()

    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))


    override func configureAppearance() {
        backgroundColor = .clear
        layer.cornerRadius = 12.0
    }

    override func prepareLayout() {
        setupDappImageViewLayout()
        setupStackViewLayout()
    }

    override func linkInteractors() {
        super.linkInteractors()

        readMoreLabel.addGestureRecognizer(tapGestureRecognizer)

        stackView.isUserInteractionEnabled = true
        subtitleContainerView.isUserInteractionEnabled = true
        subtitleStackView.isUserInteractionEnabled = true
        readMoreLabel.isUserInteractionEnabled = true
    }
}

extension WCTransactionDappMessageView {
    private func setupDappImageViewLayout() {
        dappImageView.build(URLImageViewNoStyleLayoutSheet())
        
        addSubview(dappImageView)
        dappImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
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
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(subtitleStackView)

        subtitleStackView.addArrangedSubview(subtitleContainerView)

        subtitleContainerView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        subtitleContainerView.addSubview(readMoreLabel)
        readMoreLabel.snp.makeConstraints { make in
            make.leading.equalTo(messageLabel.snp.trailing).offset(layout.current.spacing)
            make.trailing.lessThanOrEqualToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        readMoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    @objc
    private func didTap() {
        self.delegate?.wcTransactionDappMessageViewDidTapped(self)
    }
}

extension WCTransactionDappMessageView {
    func bind(_ viewModel: WCTransactionDappMessageViewModel) {
        dappImageView.load(from: viewModel.image)
        nameLabel.text = viewModel.name
        messageLabel.text = viewModel.message
        readMoreLabel.isHidden = viewModel.isReadMoreHidden

        if viewModel.message.isNilOrEmpty {
            self.subtitleStackView.hideViewInStack()
        } else {
            self.subtitleStackView.showViewInStack()
        }
    }
}

extension WCTransactionDappMessageView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let nameLabelLeadingInset: CGFloat = 16.0
        let spacing: CGFloat = 4.0
        let messageLabelVerticalInset: CGFloat = 4.0
        let imageSize = CGSize(width: 48.0, height: 48.0)
    }
}

protocol WCTransactionDappMessageViewDelegate: AnyObject {
    func wcTransactionDappMessageViewDidTapped(_ WCTransactionDappMessageView: WCTransactionDappMessageView)
}
