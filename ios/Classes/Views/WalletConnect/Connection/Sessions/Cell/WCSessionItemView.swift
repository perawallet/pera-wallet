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
//   WCSessionItemView.swift

import UIKit
import Macaroon

class WCSessionItemView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCSessionItemViewDelegate?

    private lazy var dappImageView: URLImageView = {
        let imageView = URLImageView()
        imageView.layer.cornerRadius = 20.0
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = Colors.Component.dappImageBorderColor.cgColor
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(Colors.Text.primary)
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
    }()

    private lazy var disconnectOptionsButton: UIButton = {
        let button = UIButton(type: .custom).withImage(img("icon-options", isTemplate: true))
        button.tintColor = Colors.ButtonText.secondary
        return button
    }()

    private lazy var descriptionLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.contained)
            .withTextColor(Colors.Text.secondary)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
    }()

    private lazy var statusBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Main.primary600.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12.0
        return view
    }()

    private lazy var statusLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(Colors.General.success)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withText("wallet-connect-session-connected".localized)
    }()

    private lazy var dateLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(Colors.Text.secondary)
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
    }()

    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }

    override func setListeners() {
        super.setListeners()
        disconnectOptionsButton.addTarget(self, action: #selector(notifyDelegateToOpenDisconnectionMenu), for: .touchUpInside)
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupDappImageViewLayout()
        setupDisconnectOptionsButtonLayout()
        setupNameLabelLayout()
        setupDescriptionLabelLayout()
        setupStatusBackgroundViewLayout()
        setupStatusLabelLayout()
        setupDateLabelLayout()
    }
}

extension WCSessionItemView {
    private func setupDappImageViewLayout() {
        addSubview(dappImageView)

        dappImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.leadingInset)
            make.size.equalTo(layout.current.imageSize)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupDisconnectOptionsButtonLayout() {
        addSubview(disconnectOptionsButton)

        disconnectOptionsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.trailingInset)
            make.size.equalTo(layout.current.buttonSize)
            make.top.equalToSuperview().inset(layout.current.buttonTopInset)
        }
    }

    private func setupNameLabelLayout() {
        addSubview(nameLabel)

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(dappImageView.snp.trailing).offset(layout.current.nameLabelHorizontalInset)
            make.trailing.equalTo(disconnectOptionsButton.snp.leading).offset(-layout.current.nameLabelHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }

    private func setupDescriptionLabelLayout() {
        addSubview(descriptionLabel)

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(layout.current.descriptionTopInset)
            make.trailing.equalToSuperview().inset(layout.current.trailingInset)
        }
    }

    private func setupStatusBackgroundViewLayout() {
        addSubview(statusBackgroundView)

        statusBackgroundView.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(layout.current.statusViewTopInset)
            make.height.equalTo(layout.current.statusLabelHeight)
        }
    }

    private func setupStatusLabelLayout() {
        statusBackgroundView.addSubview(statusLabel)

        statusLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.statusLabelHorizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.statusLabelVerticalInset)
        }
    }

    private func setupDateLabelLayout() {
        addSubview(dateLabel)

        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(statusBackgroundView)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.trailingInset)
            make.top.equalTo(statusBackgroundView.snp.bottom).offset(layout.current.dateLabelTopInset)
        }
    }
}

extension WCSessionItemView {
    @objc
    private func notifyDelegateToOpenDisconnectionMenu() {
        delegate?.wcSessionItemViewDidOpenDisconnectionMenu(self)
    }
}

extension WCSessionItemView {
    func bind(_ viewModel: WCSessionItemViewModel) {
        dappImageView.load(from: viewModel.image)
        nameLabel.text = viewModel.name
        descriptionLabel.text = viewModel.description
        statusLabel.text = viewModel.status
        dateLabel.text = viewModel.date
    }

    func prepareForReuse() {
        dappImageView.prepareForReuse()
        nameLabel.text = nil
        descriptionLabel.text = nil
        statusLabel.text = nil
        dateLabel.text = nil
    }
}

extension WCSessionItemView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 40.0
        let buttonTopInset: CGFloat = 32.0
        let leadingInset: CGFloat = 24.0
        let trailingInset: CGFloat = 20.0
        let nameLabelHorizontalInset: CGFloat = 16.0
        let imageSize = CGSize(width: 40.0, height: 40.0)
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let descriptionTopInset: CGFloat = 8.0
        let statusLabelHeight: CGFloat = 24.0
        let statusViewTopInset: CGFloat = 16.0
        let statusLabelVerticalInset: CGFloat = 4.0
        let statusLabelHorizontalInset: CGFloat = 8.0
        let dateLabelHorizontalInset: CGFloat = 12.0
        let dateLabelTopInset: CGFloat = 8.0
    }
}

protocol WCSessionItemViewDelegate: AnyObject {
    func wcSessionItemViewDidOpenDisconnectionMenu(_ wcSessionItemView: WCSessionItemView)
}
