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

//   SwapIntroductionScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class SwapIntroductionScreen: ScrollScreen {
    var eventHandler: Screen.EventHandler<SwapIntroductionEvent>?

    private lazy var illustrationImageView = UIImageView()
    private lazy var closeActionView = MacaroonUIKit.Button()
    private lazy var titleView = Label()
    private lazy var newBadgeView = Label()
    private lazy var bodyView = Label()
    private lazy var footerContentView = UIView()
    private lazy var providerContent = UIView()
    private lazy var poweredByTitleView = Label()
    private lazy var providerView = UIImageView()
    private lazy var primaryActionView = MacaroonUIKit.Button()
    private lazy var termsOfServiceView = ALGActiveLabel()

    private lazy var theme = SwapIntroductionScreenTheme()

    private let draft: SwapIntroductionDraft

    init(
        draft: SwapIntroductionDraft
    ) {
        self.draft = draft
        super.init()
    }

    override func configureNavigationBar() {
        navigationBarController.isNavigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentInset.top = theme.illustrationImageMaxHeight

        addUI()
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }

    override func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        super.scrollViewDidScroll(scrollView)
        updateUIWhenViewDidScroll()
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if !decelerate {
            updateUIWhenViewDidScroll()
        }
    }

    func scrollViewDidEndDecelerating(
        _ scrollView: UIScrollView
    ) {
        updateUIWhenViewDidScroll()
    }
}

extension SwapIntroductionScreen {
    private func updateUIWhenViewDidScroll() {
        updateIllustrationImageWhenViewDidScroll()
    }

    private func updateIllustrationImageWhenViewDidScroll() {
        let contentY = scrollView.contentOffset.y + scrollView.contentInset.top

        let preferredHeight = theme.illustrationImageMaxHeight - contentY

        illustrationImageView.snp.updateConstraints {
            $0.fitToHeight(max(preferredHeight, theme.illustrationImageMinHeight))
        }
    }
}

extension SwapIntroductionScreen {
    private func addUI() {
        addIllustrationImage()
        addCloseAction()
        addTitle()
        addBody()
        addFooterContent()
    }

    private func addIllustrationImage() {
        illustrationImageView.customizeAppearance(theme.illustrationImage)
        illustrationImageView.clipsToBounds = true

        view.addSubview(illustrationImageView)
        illustrationImageView.snp.makeConstraints {
            $0.fitToHeight(theme.illustrationImageMaxHeight)
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        addIllustrationImageBackground()
        addIllustrationBackground()
    }

    private func addIllustrationImageBackground() {
        let backgroundView = UIImageView()
        backgroundView.customizeAppearance(theme.illustrationImageBackground)
        backgroundView.clipsToBounds = true

        view.insertSubview(
            backgroundView,
            belowSubview: illustrationImageView
        )
        backgroundView.snp.makeConstraints {
            $0.top == illustrationImageView
            $0.leading == illustrationImageView
            $0.bottom == illustrationImageView
            $0.trailing == illustrationImageView
        }
    }

    private func addIllustrationBackground() {
        let backgroundView = GradientView()
        backgroundView.colors = [
            Colors.Defaults.background.uiColor,
            Colors.Defaults.background.uiColor.withAlphaComponent(0)
        ]

        view.insertSubview(
            backgroundView,
            belowSubview: illustrationImageView
        )
        backgroundView.snp.makeConstraints {
            let height = theme.titleTopInset
            $0.fitToHeight(height)

            $0.top == illustrationImageView.snp.bottom
            $0.leading == illustrationImageView
            $0.trailing == illustrationImageView
        }
    }

    private func addCloseAction() {
        closeActionView.customizeAppearance(theme.closeAction)

        view.addSubview(closeActionView)
        closeActionView.snp.makeConstraints {
            $0.fitToSize(theme.closeActionSize)
            $0.top == theme.closeActionTopInset
            $0.leading == theme.closeActionLeadingInset
        }

        closeActionView.addTouch(
            target: self,
            action: #selector(performCloseAction)
        )
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == theme.titleTopInset
            $0.leading == theme.titleHorizontalEdgeInsets.leading
        }

        bindTitle()

        addNewBadge()
    }

    private func addNewBadge() {
        newBadgeView.customizeAppearance(theme.newBadge)
        newBadgeView.draw(corner: theme.newBadgeCorner)
        newBadgeView.contentEdgeInsets = theme.newBadgeContentEdgeInsets

        contentView.addSubview(newBadgeView)
        newBadgeView.fitToHorizontalIntrinsicSize()
        newBadgeView.snp.makeConstraints {
            $0.width <= contentView * theme.newBadgeMaxWidthRatio
            $0.centerY == titleView
            $0.leading == titleView.snp.trailing + theme.newBadgeHorizontalEdgeInsets.leading
            $0.trailing <= theme.newBadgeHorizontalEdgeInsets.trailing
        }

        bindNewBadge()
    }

    private func addBody() {
        bodyView.customizeAppearance(theme.body)

        contentView.addSubview(bodyView)
        bodyView.fitToVerticalIntrinsicSize()
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndBody
            $0.leading == theme.bodyHorizontalEdgeInsets.leading
            $0.bottom == 0
            $0.trailing == theme.bodyHorizontalEdgeInsets.trailing
        }

        bindBody()
    }

    private func addFooterContent() {
        footerView.addSubview(footerContentView)
        footerContentView.snp.makeConstraints {
            $0.setPaddings(theme.footerContentEdgeInsets)
        }

        addProviderContent()
        addPrimaryAction()
        addTermsOfService()
    }

    private func addProviderContent() {
        footerContentView.addSubview(providerContent)
        providerContent.snp.makeConstraints {
            $0.centerX == 0
            $0.top == 0
            $0.leading >= 0
            $0.trailing <= 0
        }

        addPoweredBy()
        addProvider()
    }

    private func addPoweredBy() {
        poweredByTitleView.customizeAppearance(theme.poweredByTitle)

        providerContent.addSubview(poweredByTitleView)
        poweredByTitleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }

        bindPoweredBy()
    }

    private func addProvider() {
        providerContent.addSubview(providerView)
        providerView.fitToIntrinsicSize()
        providerView.snp.makeConstraints {
            $0.top >= 0
            $0.leading == poweredByTitleView.snp.trailing + theme.poweredByTitleLeadingInset
            $0.centerY == poweredByTitleView
            $0.bottom <= 0
            $0.trailing == 0
        }

        bindProvider()
    }

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)

        footerContentView.addSubview(primaryActionView)
        primaryActionView.contentEdgeInsets = theme.primaryActionContentEdgeInsets
        primaryActionView.snp.makeConstraints {
            $0.top == providerView.snp.bottom + theme.primaryActionTopInset
            $0.leading == 0
            $0.trailing == 0
        }

        primaryActionView.addTouch(
            target: self,
            action: #selector(performPrimaryAction)
        )
    }

    private func addTermsOfService() {
        termsOfServiceView.customizeAppearance(theme.termsOfService)

        footerContentView.addSubview(termsOfServiceView)
        termsOfServiceView.snp.makeConstraints {
            $0.top == primaryActionView.snp.bottom + theme.termsOfServiceTopInset
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        bindTermsOfService()
    }
}

extension SwapIntroductionScreen {
    private func bindTitle() {
        titleView.attributedText =
            "swap-introduction-title"
                .localized
                .titleMedium(
                    lineBreakMode: .byTruncatingTail
                )
    }

    private func bindBody() {
        bodyView.attributedText =
            "swap-introduction-body"
                .localized
                .bodyRegular()
    }

    private func bindNewBadge() {
        newBadgeView.text =
            "title-new-uppercased"
                .localized
    }

    private func bindPoweredBy() {
        poweredByTitleView.attributedText =
            "swap-introduction-powered-by-title"
                .localized
                .footnoteRegular(
                    lineBreakMode: .byTruncatingTail
                )
    }

    private func bindProvider() {
        providerView.image = draft.provider.icon.uiImage
    }

    private func bindTermsOfService() {
        let text =
            "swap-introduction-terms-of-service"
                .localized
                .footnoteRegular(alignment: .center)

        let hyperlink: ALGActiveType =
            .word("swap-introduction-terms-of-service-hyperlink".localized)

        var attributes = Typography.footnoteMediumAttributes(
            alignment: .center
        )
        attributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        termsOfServiceView.attachHyperlink(
            hyperlink,
            to: text,
            attributes: attributes
        ) {
            [unowned self] in
            self.open(draft.provider.termsOfServiceLink)
        }
    }
}

extension SwapIntroductionScreen {
    @objc
    private func performCloseAction() {
        eventHandler?(.performCloseAction)
    }

    @objc
    private func performPrimaryAction() {
        eventHandler?(.performPrimaryAction)
    }
}

enum SwapIntroductionEvent {
    case performCloseAction
    case performPrimaryAction
}
