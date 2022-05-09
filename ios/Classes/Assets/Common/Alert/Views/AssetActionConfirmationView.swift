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
//  AssetActionConfirmationView.swift

import UIKit
import MacaroonUIKit

final class AssetActionConfirmationView: View {
    weak var delegate: AssetActionConfirmationViewDelegate?

    private lazy var titleLabel = Label()
    private lazy var assetCodeLabel = Label()
    private lazy var assetNameLabel = Label()
    private lazy var verifiedImage = ImageView()
    private lazy var assetIDView = UIView()
    private lazy var assetIDLabel = Label()
    private lazy var copyIDButton = Button()
    private lazy var transactionView = HStackView()
    private lazy var transactionFeeTitleLabel = Label()
    private lazy var transactionFeeAmountLabel = Label()
    private lazy var detailLabel = Label()
    private lazy var actionButton = Button()
    private lazy var cancelButton = Button()

    func customize(_ theme: AssetActionConfirmationViewTheme) {
        addTitleLabel(theme)
        addAssetCodeLabel(theme)
        addAssetNameLabel(theme)
        addAssetIDView(theme)
        addTransactionView(theme)
        addDetailLabel(theme)
        addActionButton(theme)
        addCancelButton(theme)
    }

    func prepareLayout(_ layoutSheet: AssetActionConfirmationViewTheme) {}

    func customizeAppearance(_ styleSheet: AssetActionConfirmationViewTheme) {}

    func setListeners() {
        copyIDButton.addTouch(target: self, action: #selector(notifyDelegateToCopyAssetId))
        actionButton.addTouch(target: self, action: #selector(notifyDelegateToHandleAction))
        cancelButton.addTouch(target: self, action: #selector(notifyDelegateToCancelScreen))
    }
}

extension AssetActionConfirmationView {
    @objc
    private func notifyDelegateToHandleAction() {
        delegate?.assetActionConfirmationViewDidTapActionButton(self)
    }

    @objc
    private func notifyDelegateToCancelScreen() {
        delegate?.assetActionConfirmationViewDidTapCancelButton(self)
    }

    @objc
    private func notifyDelegateToCopyAssetId() {
        delegate?.assetActionConfirmationViewDidTapCopyIDButton(self, assetID: assetIDLabel.text)
    }
}

extension AssetActionConfirmationView {
    private func addTitleLabel(_ theme: AssetActionConfirmationViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalToSuperview().inset(theme.titleTopPadding)
        }
    }

    private func addAssetCodeLabel(_ theme: AssetActionConfirmationViewTheme) {
        assetCodeLabel.customizeAppearance(theme.assetCodeLabel)

        addSubview(assetCodeLabel)
        assetCodeLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.assetCodeLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.greaterThanHeight(theme.assetCodeLabelMinHeight)
        }
    }

    private func addAssetNameLabel(_ theme: AssetActionConfirmationViewTheme) {
        assetNameLabel.customizeAppearance(theme.assetNameLabel)

        addSubview(assetNameLabel)
        assetNameLabel.snp.makeConstraints {
            $0.top.equalTo(assetCodeLabel.snp.bottom).offset(theme.assetNameLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.greaterThanHeight(theme.assetNameLabelMinHeight)
        }
        assetNameLabel.addSeparator(theme.separator, padding: theme.separatorPadding)
    }

    private func addAssetIDView(_ theme: AssetActionConfirmationViewTheme) {
        addSubview(assetIDView)
        assetIDView.snp.makeConstraints {
            $0.top.equalTo(assetNameLabel.snp.bottom).offset(theme.assetIDPaddings.top)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        addVerifiedImage(theme)
        addAssetIDLabel(theme)
        addCopyIDButton(theme)

        assetIDView.addSeparator(theme.separator, padding: theme.separatorPadding)
    }

    private func addVerifiedImage(_ theme: AssetActionConfirmationViewTheme) {
        verifiedImage.customizeAppearance(theme.verifiedImage)

        assetIDView.addSubview(verifiedImage)
        verifiedImage.fitToIntrinsicSize()
        verifiedImage.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }

    private func addAssetIDLabel(_ theme: AssetActionConfirmationViewTheme) {
        assetIDLabel.customizeAppearance(theme.assetIDLabel)

        assetIDView.addSubview(assetIDLabel)
        assetIDLabel.snp.makeConstraints {
            $0.leading.equalTo(verifiedImage.snp.trailing).offset(theme.assetIDPaddings.leading)
            $0.leading.equalToSuperview().priority(.medium)
            $0.centerY.equalToSuperview()
        }
    }

    private func addCopyIDButton(_ theme: AssetActionConfirmationViewTheme) {
        copyIDButton.customizeAppearance(theme.copyIDButton)
        copyIDButton.contentEdgeInsets = UIEdgeInsets(theme.copyIDButtonEdgeInsets)
        copyIDButton.draw(corner: theme.copyIDButtonCorner)
        
        assetIDView.addSubview(copyIDButton)
        copyIDButton.fitToIntrinsicSize()
        copyIDButton.snp.makeConstraints {
            $0.fitToHeight(theme.copyIDButtonHeight)
            $0.leading >= assetIDLabel.snp.trailing + theme.minimumHorizontalSpacing
            $0.top.bottom.trailing.equalToSuperview()
        }
    }

    private func addTransactionView(_ theme: AssetActionConfirmationViewTheme) {
        addSubview(transactionView)
        transactionView.spacing = theme.minimumHorizontalSpacing

        transactionView.snp.makeConstraints {
            $0.top.equalTo(assetIDView.snp.bottom).offset(theme.transactionTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        addTransactionTitleLabel(theme)
        addTransactionAmountLabel(theme)
    }

    private func addTransactionTitleLabel(_ theme: AssetActionConfirmationViewTheme) {
        transactionFeeTitleLabel.customizeAppearance(theme.transactionFeeTitleLabel)

        transactionFeeTitleLabel.fitToVerticalIntrinsicSize(
            hugging: .defaultHigh,
            compression: .required
        )

        transactionFeeTitleLabel.fitToHorizontalIntrinsicSize(
            hugging: .required,
            compression: .defaultHigh
        )

        transactionView.addArrangedSubview(transactionFeeTitleLabel)
    }

    private func addTransactionAmountLabel(_ theme: AssetActionConfirmationViewTheme) {
        transactionFeeAmountLabel.customizeAppearance(theme.transactionFeeAmountLabel)

        transactionFeeAmountLabel.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )

        transactionFeeAmountLabel.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )

        transactionView.addArrangedSubview(transactionFeeAmountLabel)
    }

    private func addDetailLabel(_ theme: AssetActionConfirmationViewTheme) {
        detailLabel.customizeAppearance(theme.description)

        addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(transactionFeeTitleLabel.snp.bottom).offset(theme.transactionBottomPadding)
            $0.top.equalTo(assetIDView.snp.bottom).offset(theme.descriptionTopInset).priority(.medium)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addActionButton(_ theme: AssetActionConfirmationViewTheme) {
        actionButton.customize(theme.mainButtonTheme)

        addSubview(actionButton)
        actionButton.fitToVerticalIntrinsicSize()
        actionButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(detailLabel.snp.bottom).offset(theme.verticalInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addCancelButton(_ theme: AssetActionConfirmationViewTheme) {
        cancelButton.customize(theme.secondaryButtonTheme)

        addSubview(cancelButton)
        cancelButton.fitToVerticalIntrinsicSize()
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(actionButton.snp.bottom).offset(theme.buttonInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview().inset(theme.bottomInset + safeAreaBottom)
        }
    }
}

extension AssetActionConfirmationView: ViewModelBindable {
    func bindData(_ viewModel: AssetActionConfirmationViewModel?) {
        titleLabel.text = viewModel?.title
        assetCodeLabel.text = viewModel?.assetDisplayViewModel?.code
        assetNameLabel.text = viewModel?.assetDisplayViewModel?.name

        if !(viewModel?.assetDisplayViewModel?.isVerified ?? false) {
            verifiedImage.removeFromSuperview()
        }
        assetIDLabel.text = viewModel?.id

        if viewModel?.transactionFee.isNilOrEmpty ?? true {
            transactionView.removeFromSuperview()
        }
        transactionFeeAmountLabel.text = viewModel?.transactionFee

        detailLabel.attributedText = viewModel?.detail

        actionButton.bindData(ButtonCommonViewModel(title: viewModel?.actionTitle))
        cancelButton.bindData(ButtonCommonViewModel(title: viewModel?.cancelTitle))
    }
}

protocol AssetActionConfirmationViewDelegate: AnyObject {
    func assetActionConfirmationViewDidTapActionButton(_ assetActionConfirmationView: AssetActionConfirmationView)
    func assetActionConfirmationViewDidTapCancelButton(_ assetActionConfirmationView: AssetActionConfirmationView)
    func assetActionConfirmationViewDidTapCopyIDButton(_ assetActionConfirmationView: AssetActionConfirmationView, assetID: String?)
}
