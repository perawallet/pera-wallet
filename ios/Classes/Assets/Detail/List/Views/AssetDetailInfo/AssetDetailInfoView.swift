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
//   AssetDetailInfoView.swift

import MacaroonUIKit
import UIKit

final class AssetDetailInfoView:
    View,
    ViewModelBindable,
    ListReusable,
    UIContextMenuInteractionDelegate {
    weak var delegate: AssetDetailInfoViewDelegate?

    private lazy var yourBalanceTitleLabel = UILabel()
    private lazy var balanceLabel = UILabel()
    private lazy var secondaryValueLabel = Label()
    private lazy var topSeparator = UIView()
    private lazy var assetNameView = UIView()
    private lazy var assetNameLabel = UILabel()
    private lazy var assetIDView = Label()
    private lazy var verifiedImage = UIImageView()
    private lazy var bottomSeparator = UIView()

    private lazy var assetIDContextMenuInteraction = UIContextMenuInteraction(delegate: self)

    func setListeners() {
        assetIDView.addInteraction(assetIDContextMenuInteraction)
    }

    func customize(
        _ theme: AssetDetailInfoViewTheme
    ) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addYourBalanceTitleLabel(theme)
        addBalanceLabel(theme)
        addSecondaryValueLabel(theme)
        addTopSeparator(theme)
        addAssetNameLabel(theme)
        addAssetID(theme)
        addBottomSeparator(theme)
    }

    func customizeAppearance(
        _ styleSheet: StyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: LayoutSheet
    ) {}

    func bindData(
        _ viewModel: AssetDetailInfoViewModel?
    ) {
        if let title = viewModel?.title {
            title.load(in: yourBalanceTitleLabel)
        } else {
            yourBalanceTitleLabel.text = nil
            yourBalanceTitleLabel.attributedText = nil
        }

        if let primaryValue = viewModel?.primaryValue {
            primaryValue.load(in: balanceLabel)
        } else {
            balanceLabel.text = nil
            balanceLabel.attributedText = nil
        }

        if let secondaryValue = viewModel?.secondaryValue {
            secondaryValue.load(in: secondaryValueLabel)
        } else {
            secondaryValueLabel.text = nil
            secondaryValueLabel.attributedText = nil
        }

        if let name = viewModel?.name {
            name.load(in: assetNameLabel)
        } else {
            assetNameLabel.text = nil
            assetNameLabel.attributedText = nil
        }

        let isVerified = viewModel?.isVerified ?? false
        verifiedImage.isHidden = !isVerified

        if let id = viewModel?.id {
            id.load(in: assetIDView)
        } else {
            assetIDView.text = nil
            assetIDView.attributedText = nil
        }
    }

    class func calculatePreferredSize(
        _ viewModel: AssetDetailInfoViewModel?,
        for theme: AssetDetailInfoViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width =
            size.width -
            2 * theme.horizontalPadding
        let yourBalanceTitleSize = viewModel.title?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let amountSize = viewModel.primaryValue?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let secondaryValueLabelSize = viewModel.secondaryValue?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let nameSize = viewModel.name?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let assetIDSize = viewModel.id?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        var preferredHeight =
            theme.topPadding +
            yourBalanceTitleSize.height +
            theme.balanceLabelTopPadding +
            amountSize.height +
            theme.separatorPadding +
            theme.separator.size +
            theme.spacingBetweenSeparatorAndAssetName +
            nameSize.height +
            theme.spacingBetweenAssetNameAndAssetID +
            theme.assetIDPadding.top +
            assetIDSize.height +
            theme.assetIDPadding.bottom +
            theme.spacingBetweenAssetIDAndSeparator +
            theme.separator.size +
            theme.bottomPadding

        if !secondaryValueLabelSize.isEmpty {
            preferredHeight += theme.secondaryValueLabelTopPadding
            preferredHeight += secondaryValueLabelSize.height
        }

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

/// <mark>
/// UIContextMenuInteractionDelegate
extension AssetDetailInfoView {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        switch interaction {
        case assetIDContextMenuInteraction:
            return self.delegate?.contextMenuInteractionForAssetID(self)
        default:
            return nil
        }
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
            backgroundColor: AppColors.Shared.System.background.uiColor
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
            backgroundColor: AppColors.Shared.System.background.uiColor
        )
    }
}

extension AssetDetailInfoView {
    private func addYourBalanceTitleLabel(
        _ theme: AssetDetailInfoViewTheme
    ) {
        yourBalanceTitleLabel.customizeAppearance(theme.yourBalanceTitleLabel)

        addSubview(yourBalanceTitleLabel)
        yourBalanceTitleLabel.fitToVerticalIntrinsicSize()
        yourBalanceTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addBalanceLabel(
        _ theme: AssetDetailInfoViewTheme
    ) {
        balanceLabel.customizeAppearance(theme.balanceLabel)

        addSubview(balanceLabel)
        balanceLabel.fitToVerticalIntrinsicSize()
        balanceLabel.snp.makeConstraints {
            $0.top.equalTo(yourBalanceTitleLabel.snp.bottom).offset(theme.balanceLabelTopPadding)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addSecondaryValueLabel(
        _ theme: AssetDetailInfoViewTheme
    ) {
        secondaryValueLabel.customizeAppearance(theme.secondaryValueLabel)

        addSubview(secondaryValueLabel)
        secondaryValueLabel.fitToVerticalIntrinsicSize()
        secondaryValueLabel.snp.makeConstraints {
            $0.top.equalTo(balanceLabel.snp.bottom)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        secondaryValueLabel.contentEdgeInsets.top = theme.secondaryValueLabelTopPadding
    }

    private func addTopSeparator(
        _ theme: AssetDetailInfoViewTheme
    ) {
        topSeparator.backgroundColor = theme.separator.color

        addSubview(topSeparator)
        topSeparator.snp.makeConstraints {
            $0.top.equalTo(secondaryValueLabel.snp.bottom).offset(theme.separatorPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.fitToHeight(theme.separator.size)
        }
    }

    private func addAssetNameLabel(
        _ theme: AssetDetailInfoViewTheme)
    {
        addSubview(assetNameView)
        assetNameView.snp.makeConstraints {
            $0.top.equalTo(topSeparator.snp.bottom).offset(theme.spacingBetweenSeparatorAndAssetName)
            $0.leading.equalTo(yourBalanceTitleLabel)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }

        assetNameLabel.customizeAppearance(theme.assetNameLabel)

        assetNameView.addSubview(assetNameLabel)
        assetNameLabel.fitToVerticalIntrinsicSize()
        assetNameLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
        verifiedImage.customizeAppearance(theme.verifiedImage)
        assetNameView.addSubview(verifiedImage)
        verifiedImage.snp.makeConstraints {
            $0.leading.equalTo(assetNameLabel.snp.trailing).offset(theme.verifiedImageHorizontalSpacing)
            $0.centerY == 0
       }
    }

    private func addAssetID(
        _ theme: AssetDetailInfoViewTheme
    ) {
        assetIDView.customizeAppearance(theme.assetID)

        addSubview(assetIDView)
        assetIDView.fitToVerticalIntrinsicSize()
        assetIDView.contentEdgeInsets = theme.assetIDPadding
        assetIDView.snp.makeConstraints {
            $0.top.equalTo(assetNameView.snp.bottom).offset(theme.spacingBetweenAssetNameAndAssetID)
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }

    private func addBottomSeparator(
        _ theme: AssetDetailInfoViewTheme
    ) {
        bottomSeparator.backgroundColor = theme.separator.color

        addSubview(bottomSeparator)
        bottomSeparator.snp.makeConstraints {
            $0.top.equalTo(assetIDView.snp.bottom).offset(theme.spacingBetweenAssetIDAndSeparator)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview().inset(theme.bottomPadding)
            $0.fitToHeight(theme.separator.size)
        }
    }
}

protocol AssetDetailInfoViewDelegate: AnyObject {
    func contextMenuInteractionForAssetID(
        _ assetDetailInfoView: AssetDetailInfoView
    ) -> UIContextMenuConfiguration?
}
