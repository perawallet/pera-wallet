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
//   WCConnectionApprovalView.swift

import UIKit
import Macaroon

class WCConnectionApprovalView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCConnectionApprovalViewDelegate?

    private lazy var dappImageView: URLImageView = {
        let imageView = URLImageView()
        imageView.layer.cornerRadius = 36.0
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = Colors.Component.dappImageBorderColor.cgColor
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(Colors.Text.primary)
            .withFont(UIFont.font(withWeight: .regular(size: 18.0)))
    }()

    private lazy var urlButton: UIButton = {
        UIButton(type: .custom)
            .withAlignment(.center)
            .withTitleColor(Colors.Text.link)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()

    private lazy var accountSelectionView = WCConnectionAccountSelectionView()

    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-cancel".localized)
            .withAlignment(.center)
            .withTitleColor(Colors.ButtonText.secondary)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withBackgroundImage(img("bg-button-secondary-small"))
    }()

    private lazy var connectButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-connect".localized)
            .withAlignment(.center)
            .withTitleColor(Colors.ButtonText.primary)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withBackgroundImage(img("bg-button-primary-small"))
    }()

    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupDappImageViewLayout()
        setupTitleLabelLayout()
        setupURLButtonLayout()
        setupAccountSelectionViewLayout()
        setupConnectButtonLayout()
        setupCancelButtonLayout()
    }

    override func setListeners() {
        accountSelectionView.addTarget(self, action: #selector(notifyDelegateToOpenAccountSelection), for: .touchUpInside)
        urlButton.addTarget(self, action: #selector(notifyDelegateToOpenURL), for: .touchUpInside)
        connectButton.addTarget(self, action: #selector(notifyDelegateToApproveConnection), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(notifyDelegateToRejectConnection), for: .touchUpInside)
    }
}

extension WCConnectionApprovalView {
    private func setupDappImageViewLayout() {
        addSubview(dappImageView)

        dappImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
            make.size.equalTo(layout.current.dappImageSize)
        }
    }

    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dappImageView.snp.bottom).offset(layout.current.titleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupURLButtonLayout() {
        addSubview(urlButton)

        urlButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.urlTopInset)
            make.centerX.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
        }
    }

    private func setupAccountSelectionViewLayout() {
        addSubview(accountSelectionView)

        accountSelectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.selectionHorizontalInset)
            make.top.equalTo(urlButton.snp.bottom).offset(layout.current.verticalInset)
        }
    }

    private func setupConnectButtonLayout() {
        addSubview(connectButton)

        connectButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.equalTo(accountSelectionView.snp.bottom).offset(layout.current.verticalInset)
        }
    }

    private func setupCancelButtonLayout() {
        addSubview(cancelButton)

        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.equalTo(connectButton)
            make.size.equalTo(connectButton)
            make.trailing.equalTo(connectButton.snp.leading).offset(-layout.current.horizontalInset)
        }
    }
}

extension WCConnectionApprovalView {
    @objc
    private func notifyDelegateToApproveConnection() {
        delegate?.wcConnectionApprovalViewDidApproveConnection(self)
    }

    @objc
    private func notifyDelegateToRejectConnection() {
        delegate?.wcConnectionApprovalViewDidRejectConnection(self)
    }

    @objc
    private func notifyDelegateToOpenAccountSelection() {
        delegate?.wcConnectionApprovalViewDidSelectAccountSelection(self)
    }

    @objc
    private func notifyDelegateToOpenURL() {
        delegate?.wcConnectionApprovalViewDidOpenURL(self)
    }
}

extension WCConnectionApprovalView {
    func bind(_ viewModel: WCConnectionApprovalViewModel) {
        dappImageView.load(from: viewModel.image)
        titleLabel.attributedText = viewModel.description
        urlButton.setTitle(viewModel.urlString, for: .normal)

        if let accountSelectionViewModel = viewModel.connectionAccountSelectionViewModel {
            accountSelectionView.bind(accountSelectionViewModel)
        }
    }

    func bind(_ viewModel: WCConnectionAccountSelectionViewModel) {
        accountSelectionView.bind(viewModel)
    }
}

extension WCConnectionApprovalView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let dappImageSize = CGSize(width: 72.0, height: 72.0)
        let verifiedImageSize = CGSize(width: 20.0, height: 20.0)
        let verticalInset: CGFloat = 32.0
        let horizontalInset: CGFloat = 20.0
        let titleTopInset: CGFloat = 20.0
        let buttonHorizontalInset: CGFloat = 24.0
        let selectionHorizontalInset: CGFloat = 24.0
        let verifiedImageHorizontalInset: CGFloat = 8.0
        let urlTopInset: CGFloat = 16.0
    }
}

protocol WCConnectionApprovalViewDelegate: AnyObject {
    func wcConnectionApprovalViewDidApproveConnection(_ wcConnectionApprovalView: WCConnectionApprovalView)
    func wcConnectionApprovalViewDidRejectConnection(_ wcConnectionApprovalView: WCConnectionApprovalView)
    func wcConnectionApprovalViewDidSelectAccountSelection(_ wcConnectionApprovalView: WCConnectionApprovalView)
    func wcConnectionApprovalViewDidOpenURL(_ wcConnectionApprovalView: WCConnectionApprovalView)
}
