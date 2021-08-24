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
//   AccountsEmptyStateView.swift

import UIKit

class AccountsEmptyStateView: BaseView {

    weak var delegate: AccountsEmptyStateViewDelegate?

    private let layout = Layout<LayoutConstants>()

    private lazy var imageView = UIImageView()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(Colors.Text.primary)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()

    private lazy var detailLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(Colors.Text.tertiary)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
            .withAlignment(.center)
            .withTitleColor(Colors.ButtonText.primary)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withBackgroundColor(Colors.Main.primary600)
        button.layer.cornerRadius = 26.0
        return button
    }()

    override func configureAppearance() {
        backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
    }

    override func setListeners() {
        actionButton.addTarget(self, action: #selector(notifyDelegateToHandleAction), for: .touchUpInside)
    }

    override func prepareLayout() {
        setupImageViewLayout()
        setupTitleLabelLayout()
        setupDetailLabelLayout()
        setupActionButtonLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateButtonSize()
    }
}

extension AccountsEmptyStateView {
    private func setupImageViewLayout() {
        addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(layout.current.imageCenterOffset)
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

    private func setupDetailLabelLayout() {
        addSubview(detailLabel)

        detailLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupActionButtonLayout() {
        addSubview(actionButton)

        actionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(detailLabel.snp.bottom).offset(layout.current.buttonTopInset)
        }
    }

    private func updateButtonSize() {
        let buttonSize = CGSize(
            width: actionButton.intrinsicContentSize.width + 2 * layout.current.buttonHorizontalInset,
            height: layout.current.buttonHeight
        )

        actionButton.snp.makeConstraints { make in
            make.size.equalTo(buttonSize)
        }
    }
}

extension AccountsEmptyStateView {
    @objc
    private func notifyDelegateToHandleAction() {
        delegate?.accountsEmptyStateViewDidTapActionButton(self)
    }
}

extension AccountsEmptyStateView {
    func bind(_ viewModel: EmptyStateViewModel) {
        imageView.image = viewModel.image
        titleLabel.text = viewModel.title
        detailLabel.text = viewModel.detail
        actionButton.setTitle(viewModel.action, for: .normal)
    }
}

extension AccountsEmptyStateView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 40.0
        let imageCenterOffset: CGFloat = -100.0
        let titleTopInset: CGFloat = 16.0
        let subtitleTopInset: CGFloat = 12.0
        let buttonTopInset: CGFloat = 24.0
        let buttonHorizontalInset: CGFloat = 24.0
        let buttonHeight: CGFloat = 52.0
    }
}

protocol AccountsEmptyStateViewDelegate: AnyObject {
    func accountsEmptyStateViewDidTapActionButton(_ accountsEmptyStateView: AccountsEmptyStateView)
}

enum EmptyState {
    case accounts
}
