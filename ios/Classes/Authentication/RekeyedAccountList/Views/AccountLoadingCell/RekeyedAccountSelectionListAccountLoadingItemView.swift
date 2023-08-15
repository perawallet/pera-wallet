// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RekeyedAccountSelectionListAccountLoadingItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class RekeyedAccountSelectionListAccountLoadingItemView:
    View,
    TripleShadowDrawable,
    ListReusable,
    ShimmerAnimationDisplaying {
    var thirdShadow: MacaroonUIKit.Shadow?
    var thirdShadowLayer: CAShapeLayer = CAShapeLayer()
    var secondShadow: MacaroonUIKit.Shadow?
    var secondShadowLayer: CAShapeLayer = CAShapeLayer()

    private var theme: RekeyedAccountSelectionListAccountLoadingItemViewTheme?

    private lazy var contextView = UIView()
    private lazy var checkboxView = UIImageView()
    private lazy var iconView = ShimmerView()
    private lazy var contentView = UIView()
    private lazy var titleView = ShimmerView()
    private lazy var subtitleView = ShimmerView()
    private lazy var infoActionView = UIImageView()

    override func layoutSubviews() {
        super.layoutSubviews()

        updateUIWhenViewLayoutSubviews()
    }

    override func preferredUserInterfaceStyleDidChange() {
        super.preferredUserInterfaceStyleDidChange()

        updateUIWhenUserInterfaceStyleDidChange()
    }
    
    func customize(_ theme: RekeyedAccountSelectionListAccountLoadingItemViewTheme) {
        self.theme = theme

        drawAppearance(shadow: theme.firstShadow)
        drawAppearance(secondShadow: theme.secondShadow)
        drawAppearance(thirdShadow: theme.thirdShadow)
        
        addContext(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension RekeyedAccountSelectionListAccountLoadingItemView {
    private func updateUIWhenViewLayoutSubviews() {
        if let secondShadow = secondShadow {
            updateOnLayoutSubviews(secondShadow: secondShadow)
        }

        if let thirdShadow = thirdShadow {
            updateOnLayoutSubviews(thirdShadow: thirdShadow)
        }
    }
}

extension RekeyedAccountSelectionListAccountLoadingItemView {
    private func updateUIWhenUserInterfaceStyleDidChange() {
        drawAppearance(secondShadow: secondShadow)
        drawAppearance(thirdShadow: thirdShadow)
    }
}

extension RekeyedAccountSelectionListAccountLoadingItemView {
    private func addContext(_ theme: RekeyedAccountSelectionListAccountLoadingItemViewTheme) {
        addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextPaddings.top
            $0.leading == theme.contextPaddings.leading
            $0.bottom == theme.contextPaddings.bottom
            $0.trailing == theme.contextPaddings.trailing
        }

        addCheckbox(theme)
        addIcon(theme)
        addContent(theme)
        addInfoAction(theme)
    }

    private func addCheckbox(_ theme: RekeyedAccountSelectionListAccountLoadingItemViewTheme) {
        checkboxView.customizeAppearance(theme.checkbox)

        contextView.addSubview(checkboxView)
        checkboxView.fitToIntrinsicSize()
        checkboxView.snp.makeConstraints {
            $0.leading == 0
            $0.centerY == 0
        }
    }

    private func addIcon(_ theme: RekeyedAccountSelectionListAccountLoadingItemViewTheme) {
        iconView.draw(corner: theme.iconCorner)

        contextView.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.leading == checkboxView.snp.trailing + theme.spacingBetweenCheckboxAndIcon
            $0.centerY == 0
            $0.fitToSize(theme.iconSize)
        }
    }

    private func addContent(_ theme: RekeyedAccountSelectionListAccountLoadingItemViewTheme) {
        contextView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.centerY == 0
            $0.top >= 0
            $0.leading == iconView.snp.trailing + theme.spacingBetweenIconAndContent
            $0.bottom <= 0
        }

        addTitle(theme)
        addSubtitle(theme)
    }

    private func addTitle(_ theme: RekeyedAccountSelectionListAccountLoadingItemViewTheme) {
        titleView.draw(corner: theme.corner)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.fitToSize(theme.titleSize)
        }
    }

    private func addSubtitle(_ theme: RekeyedAccountSelectionListAccountLoadingItemViewTheme) {
        subtitleView.draw(corner: theme.corner)

        contentView.addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndSubtitle
            $0.leading == titleView
            $0.bottom == 0
            $0.fitToSize(theme.subtitleSize)
        }
    }

    private func addInfoAction(_ theme: RekeyedAccountSelectionListAccountLoadingItemViewTheme) {
        infoActionView.customizeAppearance(theme.infoAction)

        contextView.addSubview(infoActionView)
        infoActionView.fitToIntrinsicSize()
        infoActionView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading == contentView.snp.trailing + theme.spacingBetweenContentAndInfoAction
            $0.trailing == 0
        }
    }
}
