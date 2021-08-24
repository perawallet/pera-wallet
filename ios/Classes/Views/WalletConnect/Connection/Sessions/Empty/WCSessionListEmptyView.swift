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
//   WCSessionListEmptyView.swift

import UIKit

class WCSessionListEmptyView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: WCSessionListEmptyViewDelegate?

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.contained)
            .withTextColor(Colors.Text.primary)
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withText("wallet-connect-session-list-empty".localized)
    }()

    private lazy var scanQRButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("qr-scan-title".localized)
            .withAlignment(.center)
            .withTitleColor(Colors.ButtonText.primary)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withBackgroundImage(img("bg-button-primary-small"))
    }()

    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }

    override func setListeners() {
        super.setListeners()
        scanQRButton.addTarget(self, action: #selector(notifyDelegateToOpenScanQR), for: .touchUpInside)
    }

    override func prepareLayout() {
        setupTitleLabelLayout()
        setupScanQRButtonLayout()
    }
}

extension WCSessionListEmptyView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.lessThanOrEqualToSuperview().inset(layout.current.titleHorizontalInset).priority(.medium)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    private func setupScanQRButtonLayout() {
        addSubview(scanQRButton)

        scanQRButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(layout.current.buttonSize)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.buttonTopInset)
        }
    }
}

extension WCSessionListEmptyView {
    @objc
    private func notifyDelegateToOpenScanQR() {
        delegate?.wcSessionListEmptyViewDidOpenScanQR(self)
    }
}

extension WCSessionListEmptyView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleHorizontalInset: CGFloat = 40.0
        let titleCenterOffset: CGFloat = 60.0
        let buttonTopInset: CGFloat = 32.0
        let buttonSize = CGSize(width: 152.0, height: 52.0)
    }
}

protocol WCSessionListEmptyViewDelegate: AnyObject {
    func wcSessionListEmptyViewDidOpenScanQR(_ wcSessionListEmptyView: WCSessionListEmptyView)
}
