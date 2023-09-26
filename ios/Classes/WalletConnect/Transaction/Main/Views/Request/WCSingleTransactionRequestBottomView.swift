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
//   WCSingleTransactionRequestBottomView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class WCSingleTransactionRequestBottomView: BaseView {
    private(set) lazy var showTransactionDetailsButton = MacaroonUIKit.Button()
    private lazy var warningLabel = UILabel()
    private lazy var warningIcon = UIImageView()
    private lazy var networkFeeTitleLabel = UILabel()
    private lazy var networkFeeLabel = UILabel()
    private lazy var assetIcon = UIImageView()
    private lazy var assetTitleLabel = UILabel()
    private lazy var assetAmountLabel = UILabel()

    private lazy var theme = WCSingleTransactionRequestBottomViewTheme()

    override func configureAppearance() {
        super.configureAppearance()

        showTransactionDetailsButton.customizeAppearance(theme.showTransactionDetailsButton)
        warningLabel.customizeAppearance(theme.warningLabel)
        warningIcon.customizeAppearance(theme.warningIcon)
        networkFeeTitleLabel.customizeAppearance(theme.networkFeeTitleLabel)
        networkFeeLabel.customizeAppearance(theme.networkFeeLabel)
        assetIcon.customizeAppearance(theme.assetIcon)
        assetTitleLabel.customizeAppearance(theme.assetTitleLabel)
        assetAmountLabel.customizeAppearance(theme.assetAmountLabel)
    }

    override func prepareLayout() {
        super.prepareLayout()

        addShowTransactionDetailsButton()
        addWarningView()
        addNetworkView()
        addAssetView()
    }
}

extension WCSingleTransactionRequestBottomView {
    private func addShowTransactionDetailsButton() {
        addSubview(showTransactionDetailsButton)
        showTransactionDetailsButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(theme.defaultHorizontalInset)
        }

        showTransactionDetailsButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func addWarningView() {
        addSubview(warningLabel)
        warningLabel.snp.makeConstraints { make in
            make.centerY.equalTo(showTransactionDetailsButton)
            make.trailing.equalToSuperview().inset(theme.defaultHorizontalInset)
        }

        addSubview(warningIcon)
        warningIcon.snp.makeConstraints { make in
            make.centerY.equalTo(warningLabel)
            make.trailing.equalTo(warningLabel.snp.leading).offset(theme.warningIconTrailingOffset)
            make.leading.greaterThanOrEqualTo(showTransactionDetailsButton.snp.trailing).offset(theme.warningIconLeadingOffset)
        }
    }

    private func addNetworkView() {
        addSubview(networkFeeLabel)
        networkFeeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(showTransactionDetailsButton.snp.top).offset(theme.showTransactionButtonTopOffset)
            make.trailing.equalToSuperview().inset(theme.defaultHorizontalInset)
        }

        addSubview(networkFeeTitleLabel)
        networkFeeTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(networkFeeLabel)
            make.leading.equalToSuperview().inset(theme.defaultHorizontalInset)
            make.trailing.greaterThanOrEqualTo(networkFeeLabel.snp.leading).offset(theme.networkFeeTitleLabelTrailingOffset).priority(.low)
        }

        networkFeeTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func addAssetView() {
        addSubview(assetAmountLabel)
        assetAmountLabel.snp.makeConstraints { make in
            make.bottom.equalTo(networkFeeTitleLabel.snp.top).offset(theme.networkFeeTitleLabelBottomOffset)
            make.trailing.equalToSuperview().inset(theme.defaultHorizontalInset)
        }

        addSubview(assetIcon)
        assetIcon.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(theme.defaultHorizontalInset)
            make.bottom.equalTo(networkFeeTitleLabel.snp.top).offset(theme.networkFeeTitleLabelBottomOffset)
            make.fitToSize(theme.assetIconSize)
        }

        addSubview(assetTitleLabel)
        assetTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(assetAmountLabel)
            make.leading.equalTo(assetIcon.snp.trailing).offset(theme.assetIconLeadingOffset)
            make.trailing.lessThanOrEqualTo(assetAmountLabel.snp.leading).offset(-theme.networkFeeTitleLabelTrailingOffset)
        }

        assetTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}

extension WCSingleTransactionRequestBottomView {
    func bind(_ viewModel: WCSingleTransactionRequestBottomViewModel?) {
        networkFeeLabel.text = viewModel?.networkFee
        assetTitleLabel.text = viewModel?.senderAddress
        warningLabel.text = viewModel?.warningMessage
        warningIcon.isHidden = viewModel?.warningMessage.isNilOrEmpty ?? true
        assetIcon.image = viewModel?.assetIcon
        assetAmountLabel.text = viewModel?.balance
        showTransactionDetailsButton.setTitle(viewModel?.showDetailsActionTitle, for: .normal)
    }
}
