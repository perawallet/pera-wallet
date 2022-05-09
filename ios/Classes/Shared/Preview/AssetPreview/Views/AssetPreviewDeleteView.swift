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

//   AssetPreviewDeleteView.swift

import UIKit
import MacaroonUIKit

final class AssetPreviewDeleteView:
    View,
    ViewModelBindable,
    UIInteractionObservable,
    UIControlInteractionPublisher,
    ListReusable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .delete: UIControlInteraction()
    ]
    
    private lazy var iconView = AssetImageView()
    private lazy var contentView = UIView()
    private lazy var titleLabel = Label()
    private lazy var verifiedIconView = ImageView()
    private lazy var subtitleLabel = Label()
    private lazy var accessoryView = UIView()
    private lazy var primaryValueLabel = Label()
    private lazy var secondaryValueLabel = Label()
    private lazy var deleteButton = Button()
    
    func customize(_ theme: AssetPreviewDeleteViewTheme) {
        addIconView(theme)
        addContent(theme)
        addAccessory(theme)
        addActionButton(theme)
    }
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension AssetPreviewDeleteView {
    class func calculatePreferredSize(
        _ viewModel: AssetPreviewViewModel?,
        for theme: AssetPreviewDeleteViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }
        
        let width = size.width
        let iconSize = theme.iconSize
        let titleSize = viewModel.title.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let subtitleSize = viewModel.subtitle.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let primaryAccessorySize = viewModel.primaryAccessory.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let secondaryAccessorySize = viewModel.secondaryAccessory.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let buttonSize = theme.buttonSize
        let accessoryIconSize = viewModel.verifiedIcon?.size ?? .zero
        let contentHeight = max(titleSize.height, accessoryIconSize.height) + subtitleSize.height
        let accessoryHeight = primaryAccessorySize.height + secondaryAccessorySize.height
        let preferredHeight = max(iconSize.h, max(contentHeight, accessoryHeight), buttonSize.h)
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AssetPreviewDeleteView {
    private func addIconView(_ theme: AssetPreviewDeleteViewTheme) {
        iconView.customize(AssetImageViewTheme())

        addSubview(iconView)
        iconView.fitToIntrinsicSize()
        
        iconView.snp.makeConstraints {
            $0.leading == 0
            $0.centerY == 0
            $0.fitToSize(theme.iconSize)
        }
    }
    
    private func addContent(_ theme: AssetPreviewDeleteViewTheme) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width >= self * theme.contentMinWidthRatio
            $0.top == 0
            $0.leading == iconView.snp.trailing + theme.horizontalPadding
            $0.bottom == 0
        }

        addTitle(theme)
        addSubtitle(theme)
    }
    
    private func addTitle(_ theme: AssetPreviewDeleteViewTheme) {
        titleLabel.customizeAppearance(theme.title)
        
        contentView.addSubview(titleLabel)
        titleLabel.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        titleLabel.fitToHorizontalIntrinsicSize(
            hugging: .required,
            compression: .defaultHigh
        )
        
        titleLabel.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
        }
        
        addVerifiedIcon(theme)
    }
    
    private func addVerifiedIcon(_ theme: AssetPreviewDeleteViewTheme) {
        verifiedIconView.customizeAppearance(theme.verifiedIcon)
        
        contentView.addSubview(verifiedIconView)
        verifiedIconView.fitToIntrinsicSize()
        
        verifiedIconView.snp.makeConstraints {
            $0.centerY == titleLabel
            $0.leading == titleLabel.snp.trailing + theme.verifiedIconLeadingPadding
            $0.trailing <= 0
        }
    }
    
    private func addSubtitle(_ theme: AssetPreviewDeleteViewTheme) {
        subtitleLabel.customizeAppearance(theme.subtitle)
        
        contentView.addSubview(subtitleLabel)
        
        subtitleLabel.fitToVerticalIntrinsicSize()
        subtitleLabel.fitToHorizontalIntrinsicSize(
            hugging: .required,
            compression: .defaultLow
        )
        
        subtitleLabel.snp.makeConstraints {
            $0.top == titleLabel.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }
    }
    
    private func addAccessory(_ theme: AssetPreviewDeleteViewTheme) {
        addSubview(accessoryView)
        accessoryView.snp.makeConstraints {
            $0.top == 0
            $0.leading == contentView.snp.trailing + theme.spacingBetweenContents
            $0.bottom == 0
        }
        
        addPrimaryValue(theme)
        addSecondaryValue(theme)
    }
    
    private func addPrimaryValue(_ theme: AssetPreviewDeleteViewTheme) {
        primaryValueLabel.customizeAppearance(theme.primaryValue)
        
        accessoryView.addSubview(primaryValueLabel)
        
        primaryValueLabel.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        primaryValueLabel.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        
        primaryValueLabel.snp.makeConstraints {
            $0.top == 0
            $0.trailing == 0
            $0.leading >= 0
        }
    }
    
    private func addSecondaryValue(_ theme: AssetPreviewDeleteViewTheme) {
        secondaryValueLabel.customizeAppearance(theme.secondaryValue)

        accessoryView.addSubview(secondaryValueLabel)

        secondaryValueLabel.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        secondaryValueLabel.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .defaultLow
        )

        secondaryValueLabel.snp.makeConstraints {
            $0.top == primaryValueLabel.snp.bottom
            $0.bottom == 0
            $0.trailing == 0
            $0.leading >= 0
        }
    }
    
    private func addActionButton(_ theme: AssetPreviewDeleteViewTheme) {
        deleteButton.customizeAppearance(theme.button)
        deleteButton.draw(corner: theme.buttonCorner)
        deleteButton.draw(shadow: theme.buttonFirstShadow)
        deleteButton.draw(secondShadow: theme.buttonSecondShadow)
        deleteButton.draw(thirdShadow: theme.buttonThirdShadow)
        
        addSubview(deleteButton)
        deleteButton.snp.makeConstraints {
            $0.fitToSize(theme.buttonSize)
            $0.leading == accessoryView.snp.trailing + theme.buttonLeadingPadding
            $0.trailing == 0
            $0.centerY == 0
        }
        
        startPublishing(
            event: .delete,
            for: deleteButton
        )
    }
}

extension AssetPreviewDeleteView {
    func bindData(_ viewModel: AssetPreviewViewModel?) {
        iconView.bindData(viewModel?.assetImageViewModel)
        titleLabel.editText = viewModel?.title
        verifiedIconView.image = viewModel?.verifiedIcon
        subtitleLabel.editText = viewModel?.subtitle
        primaryValueLabel.editText = viewModel?.primaryAccessory
        secondaryValueLabel.editText = viewModel?.secondaryAccessory
    }

    func prepareForReuse() {
        iconView.prepareForReuse()
        verifiedIconView.image = nil
        titleLabel.editText = nil
        subtitleLabel.editText = nil
        primaryValueLabel.editText = nil
        secondaryValueLabel.editText = nil
    }
}

extension AssetPreviewDeleteView {
    enum Event {
        case delete
    }
}
