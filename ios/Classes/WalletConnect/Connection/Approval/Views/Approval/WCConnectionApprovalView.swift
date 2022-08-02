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
//   WCConnectionApprovalView.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class WCConnectionApprovalView: View {
    weak var delegate: WCConnectionApprovalViewDelegate?

    private lazy var dappImageView = URLImageView()
    private lazy var titleLabel = UILabel()
    private lazy var urlButton = UIButton()

    private lazy var accountSelectionView = WCConnectionAccountSelectionView(theme: WCConnectionAccountSelectionViewTheme()) {
        $0.showsArrowImageView = hasMultipleAccounts
    }

    private lazy var cancelButton = UIButton()
    private lazy var connectButton = UIButton()

    private let hasMultipleAccounts: Bool

    init(hasMultipleAccounts: Bool) {
        self.hasMultipleAccounts = hasMultipleAccounts
        super.init(frame: .zero)

        customize(WCConnectionApprovalViewTheme())
        setListeners()
    }

    func customize(_ theme: WCConnectionApprovalViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addDappImageView(theme)
        addTitleLabel(theme)
        addURLButton(theme)
        addAccountSelectionView(theme)
        addConnectButton(theme)
        addCancelButton(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}

    func setListeners() {
        if hasMultipleAccounts {
            accountSelectionView.addTarget(self, action: #selector(notifyDelegateToOpenAccountSelection), for: .touchUpInside)
        }
        
        urlButton.addTarget(self, action: #selector(notifyDelegateToOpenURL), for: .touchUpInside)
        connectButton.addTarget(self, action: #selector(notifyDelegateToApproveConnection), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(notifyDelegateToRejectConnection), for: .touchUpInside)
    }
}

extension WCConnectionApprovalView {
    private func addDappImageView(_ theme: WCConnectionApprovalViewTheme) {
        dappImageView.build(URLImageViewNoStyleLayoutSheet())
        dappImageView.draw(corner: theme.dappImageViewCorner)

        addSubview(dappImageView)
        dappImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.imageTopInset)
            $0.centerX.equalToSuperview()
            $0.fitToSize(theme.dappImageSize)
        }
    }

    private func addTitleLabel(_ theme: WCConnectionApprovalViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(dappImageView.snp.bottom).offset(theme.titleTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addURLButton(_ theme: WCConnectionApprovalViewTheme) {
        urlButton.customizeAppearance(theme.URLButton)

        addSubview(urlButton)
        urlButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.urlTopInset)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.lessThanOrEqualToSuperview().inset(theme.horizontalInset).priority(.medium)
        }
    }

    private func addAccountSelectionView(_ theme: WCConnectionApprovalViewTheme) {
        addSubview(accountSelectionView)
        accountSelectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(urlButton.snp.bottom).offset(theme.verticalInset)
        }
    }

    private func addConnectButton(_ theme: WCConnectionApprovalViewTheme) {
        connectButton.customizeAppearance(theme.connectButton)
        connectButton.contentEdgeInsets = UIEdgeInsets(theme.buttonContentEdgeInset)
        connectButton.layer.cornerRadius = theme.buttonCorner.radius

        addSubview(connectButton)
        connectButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(accountSelectionView.snp.bottom).offset(theme.verticalInset)
            $0.bottom.lessThanOrEqualToSuperview().inset(theme.bottomInset)
        }
    }

    private func addCancelButton(_ theme: WCConnectionApprovalViewTheme) {
        cancelButton.customizeAppearance(theme.cancelButton)
        cancelButton.contentEdgeInsets = UIEdgeInsets(theme.buttonContentEdgeInset)
        cancelButton.layer.cornerRadius = theme.buttonCorner.radius

        addSubview(cancelButton)
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.top.bottom.size.equalTo(connectButton)
            $0.trailing.equalTo(connectButton.snp.leading).offset(-theme.horizontalInset)
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
    func bindData(_ viewModel: WCConnectionApprovalViewModel) {
        dappImageView.load(from: viewModel.image)
        titleLabel.attributedText = viewModel.description
        urlButton.setTitle(viewModel.urlString, for: .normal)
    }

    func bindData(_ viewModel: WCConnectionAccountSelectionViewModel) {
        accountSelectionView.bindData(viewModel)
    }
}

protocol WCConnectionApprovalViewDelegate: AnyObject {
    func wcConnectionApprovalViewDidApproveConnection(_ wcConnectionApprovalView: WCConnectionApprovalView)
    func wcConnectionApprovalViewDidRejectConnection(_ wcConnectionApprovalView: WCConnectionApprovalView)
    func wcConnectionApprovalViewDidSelectAccountSelection(_ wcConnectionApprovalView: WCConnectionApprovalView)
    func wcConnectionApprovalViewDidOpenURL(_ wcConnectionApprovalView: WCConnectionApprovalView)
}
