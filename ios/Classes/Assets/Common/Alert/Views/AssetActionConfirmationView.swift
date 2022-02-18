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

    private lazy var titleLabel = UILabel()
    private lazy var assetCodeLabel = UILabel()
    private lazy var assetNameLabel = UILabel()
    private lazy var verifiedImage = UIImageView()
    private lazy var assetIDLabel = UILabel()
    private lazy var copyIDButton = Button()
    private lazy var detailLabel = UILabel()
    private lazy var actionButton = Button()
    private lazy var cancelButton = Button()

    func customize(_ theme: AssetActionConfirmationViewTheme) {
        addTitleLabel(theme)
        addAssetCodeLabel(theme)
        addAssetNameLabel(theme)
        addVerifiedImage(theme)
        addAssetIDLabel(theme)
        addCopyIDButton(theme)
        addDetailLabel(theme)
        addActionButton(theme)
        addCancelButton(theme)
    }
    
    func prepareLayout(_ layoutSheet: AssetActionConfirmationViewTheme) {}

    func customizeAppearance(_ styleSheet: AssetActionConfirmationViewTheme) {}

    func setListeners() {
        copyIDButton.addTarget(self, action: #selector(notifyDelegateToCopyAssetId), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(notifyDelegateToHandleAction), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCancelScreen), for: .touchUpInside)
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
            $0.top.equalToSuperview().inset(theme.titleTopPadding)
        }
    }

    private func addAssetCodeLabel(_ theme: AssetActionConfirmationViewTheme) {
        assetCodeLabel.customizeAppearance(theme.assetCodeLabel)

        addSubview(assetCodeLabel)
        assetCodeLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.assetCodeLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addAssetNameLabel(_ theme: AssetActionConfirmationViewTheme) {
        assetNameLabel.customizeAppearance(theme.assetNameLabel)

        addSubview(assetNameLabel)
        assetNameLabel.snp.makeConstraints {
            $0.top.equalTo(assetCodeLabel.snp.bottom).offset(theme.assetNameLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
        assetNameLabel.addSeparator(theme.topSeparator, padding: theme.topSeparatorPadding)
    }

    private func addVerifiedImage(_ theme: AssetActionConfirmationViewTheme) {
        verifiedImage.customizeAppearance(theme.verifiedImage)

        addSubview(verifiedImage)
        verifiedImage.snp.makeConstraints {
            $0.top.equalTo(assetNameLabel.snp.bottom).offset(theme.assetIDPaddings.top)
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
        }
        verifiedImage.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func addAssetIDLabel(_ theme: AssetActionConfirmationViewTheme) {
        assetIDLabel.customizeAppearance(theme.assetIDLabel)

        addSubview(assetIDLabel)
        assetIDLabel.snp.makeConstraints {
            $0.leading.equalTo(verifiedImage.snp.trailing).offset(theme.assetIDPaddings.leading)
            $0.leading.equalToSuperview().inset(theme.horizontalPadding).priority(.medium)
            $0.top.equalTo(assetNameLabel.snp.bottom).offset(theme.assetIDPaddings.top)
            $0.trailing.equalToSuperview().inset(theme.assetIDPaddings.trailing)
        }
    }

    private func addCopyIDButton(_ theme: AssetActionConfirmationViewTheme) {
        copyIDButton.customizeAppearance(theme.copyIDButton)
        copyIDButton.draw(corner: theme.copyIDButtonCorner)
        
        addSubview(copyIDButton)
        copyIDButton.snp.makeConstraints {
            $0.fitToSize(theme.copyIDButtonSize)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.centerY.equalTo(assetIDLabel.snp.centerY)
        }
    }
    
    private func addDetailLabel(_ theme: AssetActionConfirmationViewTheme) {
        detailLabel.customizeAppearance(theme.description)

        addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(assetIDLabel.snp.bottom).offset(theme.descriptionTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        detailLabel.addSeparator(theme.bottomSeparator, padding: theme.bottomSeparatorPadding)
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
        assetIDLabel.text = viewModel?.id
        detailLabel.attributedText = viewModel?.detail
        actionButton.bindData(ButtonCommonViewModel(title: viewModel?.actionTitle))
        cancelButton.bindData(ButtonCommonViewModel(title: viewModel?.cancelTitle))

        if !(viewModel?.assetDisplayViewModel?.isVerified ?? false) {
            verifiedImage.removeFromSuperview()
        }

        assetNameLabel.text = viewModel?.assetDisplayViewModel?.name
        assetCodeLabel.text = viewModel?.assetDisplayViewModel?.code
    }
}

protocol AssetActionConfirmationViewDelegate: AnyObject {
    func assetActionConfirmationViewDidTapActionButton(_ assetActionConfirmationView: AssetActionConfirmationView)
    func assetActionConfirmationViewDidTapCancelButton(_ assetActionConfirmationView: AssetActionConfirmationView)
    func assetActionConfirmationViewDidTapCopyIDButton(_ assetActionConfirmationView: AssetActionConfirmationView, assetID: String?)
}
