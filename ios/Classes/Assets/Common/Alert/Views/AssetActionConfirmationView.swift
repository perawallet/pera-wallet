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

final class AssetActionConfirmationView:
    View,
    UIContextMenuInteractionDelegate {
    weak var delegate: AssetActionConfirmationViewDelegate?

    private lazy var titleLabel = Label()
    private lazy var assetNameView = PrimaryTitleView()
    private lazy var assetIDView = UIView()
    private lazy var assetIDLabel = Label()
    private lazy var copyIDButton = Button()
    private lazy var warningIconView = ImageView()
    private lazy var detailLabel = Label()
    private lazy var actionButton = Button()
    private lazy var cancelButton = Button()

    private lazy var assetIDMenuInteraction = UIContextMenuInteraction(delegate: self)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
    }

    func customize(_ theme: AssetActionConfirmationViewTheme) {
        addTitleLabel(theme)
        addAssetName(theme)
        addAssetIDView(theme)
        addWarningIcon(theme)
        addDetailLabel(theme)
        addActionButton(theme)
        addCancelButton(theme)
    }

    func prepareLayout(_ layoutSheet: AssetActionConfirmationViewTheme) {}

    func customizeAppearance(_ styleSheet: AssetActionConfirmationViewTheme) {}

    func setListeners() {
        assetIDView.addInteraction(assetIDMenuInteraction)
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
        delegate?.assetActionConfirmationViewDidTapCopyIDButton(self)
    }
}

extension AssetActionConfirmationView {
    private func addTitleLabel(_ theme: AssetActionConfirmationViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)

        addSubview(titleLabel)
        titleLabel.fitToVerticalIntrinsicSize()
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalToSuperview().inset(theme.titleTopPadding)
        }
    }

    private func addAssetName(_ theme: AssetActionConfirmationViewTheme) {
        assetNameView.customize(theme.assetName)

        addSubview(assetNameView)
        assetNameView.fitToVerticalIntrinsicSize()
        assetNameView.snp.makeConstraints {
            $0.top == titleLabel.snp.bottom + theme.assetNameTopPadding
            $0.leading == theme.horizontalPadding
            $0.trailing == theme.horizontalPadding
        }

        attachSeparator(
            theme.assetNameSeparator,
            to: assetNameView,
            margin: theme.spacingBetweenAssetNameAndSeparator
        )
    }

    private func addAssetIDView(_ theme: AssetActionConfirmationViewTheme) {
        addSubview(assetIDView)
        assetIDView.snp.makeConstraints {
            $0.top.equalTo(assetNameView.snp.bottom).offset(theme.assetIDPaddings.top)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        addAssetIDLabel(theme)
        addCopyIDButton(theme)

        assetIDView.addSeparator(theme.separator, padding: theme.separatorPadding)
    }

    private func addAssetIDLabel(_ theme: AssetActionConfirmationViewTheme) {
        assetIDLabel.customizeAppearance(theme.assetIDLabel)

        assetIDView.addSubview(assetIDLabel)
        assetIDLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
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

    private func addWarningIcon(_ theme: AssetActionConfirmationViewTheme) {
        warningIconView.customizeAppearance(theme.warningIcon)

        addSubview(warningIconView)
        warningIconView.contentEdgeInsets = theme.warningIconContentEdgeInsets
        warningIconView.fitToIntrinsicSize()
        warningIconView.snp.makeConstraints {
            $0.top.equalTo(assetIDView.snp.bottom).offset(theme.transactionBottomPadding)
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addDetailLabel(_ theme: AssetActionConfirmationViewTheme) {
        detailLabel.customizeAppearance(theme.detail)

        addSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(warningIconView)
            $0.leading.equalTo(warningIconView.snp.trailing)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addActionButton(_ theme: AssetActionConfirmationViewTheme) {
        actionButton.customize(theme.mainButtonTheme)

        addSubview(actionButton)
        actionButton.fitToVerticalIntrinsicSize()
        actionButton.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(theme.spacingBetweenButtonAndDetail)
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
            $0.bottom.equalToSuperview().inset(theme.bottomInset)
        }
    }
}

extension AssetActionConfirmationView {
     func contextMenuInteraction(
         _ interaction: UIContextMenuInteraction,
         configurationForMenuAtLocation location: CGPoint
     ) -> UIContextMenuConfiguration? {
         delegate?.contextMenuInteractionForAssetID(in: self)
     }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let view = interaction.view else {
            return nil
        }

        return UITargetedPreview(
            view: view,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let view = interaction.view else {
            return nil
        }

        return UITargetedPreview(
            view: view,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }
 }

extension AssetActionConfirmationView: ViewModelBindable {
    func bindData(_ viewModel: AssetActionConfirmationViewModel?) {
        titleLabel.attributedText = viewModel?.title
        titleLabel.textColor = viewModel?.titleColor?.uiColor
        assetNameView.bindData(viewModel?.name)
        assetIDLabel.text = viewModel?.id
        detailLabel.attributedText = viewModel?.detail

        actionButton.bindData(ButtonCommonViewModel(title: viewModel?.actionTitle))
        cancelButton.bindData(ButtonCommonViewModel(title: viewModel?.cancelTitle))
    }
}

protocol AssetActionConfirmationViewDelegate: AnyObject {
    func assetActionConfirmationViewDidTapActionButton(_ assetActionConfirmationView: AssetActionConfirmationView)
    func assetActionConfirmationViewDidTapCancelButton(_ assetActionConfirmationView: AssetActionConfirmationView)
    func assetActionConfirmationViewDidTapCopyIDButton(_ assetActionConfirmationView: AssetActionConfirmationView)
    func contextMenuInteractionForAssetID(
        in assetActionConfirmationView: AssetActionConfirmationView
    ) -> UIContextMenuConfiguration?
}
