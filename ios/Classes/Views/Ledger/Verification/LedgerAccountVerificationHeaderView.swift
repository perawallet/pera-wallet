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
//   LedgerAccountVerificationHeaderView.swift

import UIKit

class LedgerAccountVerificationHeaderView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var ledgerDeviceConnectionView = LedgerDeviceConnectionView()

    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 28.0)))
            .withTextColor(Colors.Text.primary)
            .withLine(.contained)
            .withAlignment(.center)
            .withText("ledger-verify-header-title".localized)
    }()

    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 16.0)))
            .withTextColor(Colors.Text.secondary)
            .withLine(.contained)
            .withAlignment(.center)
            .withText("ledger-verify-header-subtitle".localized)
    }()

    override func configureAppearance() {
        backgroundColor = .clear
    }

    override func prepareLayout() {
        setupLedgerDeviceConnectionViewLayout()
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
    }
}

extension LedgerAccountVerificationHeaderView {
    private func setupLedgerDeviceConnectionViewLayout() {
        addSubview(ledgerDeviceConnectionView)

        ledgerDeviceConnectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.connectionViewTopInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.titleHorizontalInset)
            make.top.equalTo(ledgerDeviceConnectionView.snp.bottom).offset(layout.current.titleTopInset)
        }
    }

    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)

        subtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.subtitleHorizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.bottom.equalToSuperview()
        }
    }
}

extension LedgerAccountVerificationHeaderView {
    func startConnectionAnimation() {
        ledgerDeviceConnectionView.startAnimation()
    }

    func stopConnectionAnimation() {
        ledgerDeviceConnectionView.stopAnimation()
    }
}

extension LedgerAccountVerificationHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let connectionViewTopInset: CGFloat = 12.0
        let titleTopInset: CGFloat = 28.0
        let titleHorizontalInset: CGFloat = 48.0
        let subtitleTopInset: CGFloat = 16.0
        let subtitleHorizontalInset: CGFloat = 36.0
    }
}
