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

//   VerificationInfoViewController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AsaVerificationInfoScreen: ScrollScreen {
    var eventHandler: Screen.EventHandler<AsaVerificationInfoEvent>?

    private lazy var cancelActionView = MacaroonUIKit.Button()
    private lazy var illustrationView = ImageView()
    private lazy var titleView = Label()
    private lazy var bodyView = Label()
    private lazy var primaryActionView = MacaroonUIKit.Button()

    private lazy var theme = AsaVerificationInfoScreenTheme()

    override var shouldShowNavigationBar: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUIWhenViewDidLayoutSubviews()
    }

    override func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        super.scrollViewDidScroll(scrollView)
        updateUIWhenViewDidScroll()
    }
}

extension AsaVerificationInfoScreen {
    private func addUI() {
        addIllustration()
        addCancelAction()
        addTitle()
        addBody()
        addPrimaryAction()
    }

    private func updateUIWhenViewDidLayoutSubviews() {
        updateContentWhenViewDidLayoutSubviews()
    }

    private func updateUIWhenViewDidScroll() {
        updateIllustrationWhenViewDidScroll()
    }

    private func updateContentWhenViewDidLayoutSubviews() {
        let inset = illustrationView.bounds.height
        scrollView.setContentInset(top: inset)
    }

    private func addIllustration() {
        illustrationView.customizeAppearance(theme.illustration)
        illustrationView.clipsToBounds = true
        illustrationView.isUserInteractionEnabled = false

        view.addSubview(illustrationView)
        illustrationView.snp.makeConstraints {
            $0.fitToHeight(theme.illustrationMaxHeight)
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        addIllustrationBackground()
    }

    private func addIllustrationBackground() {
        let backgroundView = GradientView()
        backgroundView.colors = [
            Colors.Defaults.background.uiColor,
            Colors.Defaults.background.uiColor.withAlphaComponent(0)
        ]

        view.insertSubview(
            backgroundView,
            belowSubview: illustrationView
        )
        backgroundView.snp.makeConstraints {
            let height = theme.titleTopInset
            $0.fitToHeight(height)

            $0.top == illustrationView.snp.bottom
            $0.leading == illustrationView
            $0.trailing == illustrationView
        }
    }

    private func updateIllustrationWhenViewDidScroll() {
        illustrationView.snp.updateConstraints {
            let preferredInset = -(scrollView.contentInset.top + scrollView.contentOffset.y)
            let maxInset = theme.illustrationMaxHeight - theme.illustrationMinHeight
            let inset = max(preferredInset, -maxInset)
            $0.top == inset
        }
    }

    private func addCancelAction() {
        cancelActionView.customizeAppearance(theme.closeAction)

        view.addSubview(cancelActionView)
        cancelActionView.snp.makeConstraints {
            $0.fitToSize(theme.closeActionSize)
            $0.top == theme.closeActionTopInset
            $0.leading == theme.closeActionLeadingInset
        }

        cancelActionView.addTouch(
            target: self,
            action: #selector(cancel)
        )
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == theme.titleTopInset
            $0.leading == theme.titleHorizontalEdgeInsets.leading
            $0.trailing == theme.titleHorizontalEdgeInsets.trailing
        }

        bindTitle()
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

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)

        footerView.addSubview(primaryActionView)
        primaryActionView.contentEdgeInsets = theme.primaryActionContentEdgeInsets
        primaryActionView.snp.makeConstraints {
            $0.top == theme.primaryActionEdgeInsets.top
            $0.leading == theme.primaryActionEdgeInsets.leading
            $0.bottom == theme.primaryActionEdgeInsets.bottom
            $0.trailing == theme.primaryActionEdgeInsets.trailing
        }

        primaryActionView.addTouch(
            target: self,
            action: #selector(performPrimaryAction)
        )
    }
}

extension AsaVerificationInfoScreen {
    private func bindTitle() {
        titleView.attributedText = "verification-info-title"
            .localized
            .titleMedium()
    }

    /// <todo>
    /// Support it in 'Macaroon' properly
    private func bindBody() {
        let hightlightedTexts = [
            "verification-info-body-first-highlight".localized,
            "verification-info-body-second-highlight".localized,
            "verification-info-body-third-highlight".localized
        ]
        let body = "verification-info-body".localized
        let attributedBody = NSMutableAttributedString(string: body)
        
        addBodyNormalAttributes(in: attributedBody)
        addBodyHighlightedAttributes(
            for: hightlightedTexts,
            in: attributedBody
        )

        bodyView.attributedText = attributedBody
    }

    private func addBodyNormalAttributes(
        in attributedBody: NSMutableAttributedString
    ) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineHeightMultiple = 1.23
        paragraphStyle.paragraphSpacing = 16

        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.font] = Fonts.DMSans.regular.make(15).uiFont
        attributes[.paragraphStyle] = paragraphStyle

        let body = attributedBody.string
        let range = NSRange(location: 0, length: body.count)

        attributedBody.addAttributes(
            attributes,
            range: range
        )
    }

    private func addBodyHighlightedAttributes(
        for texts: [String],
        in attributedBody: NSMutableAttributedString
    ) {
        let body = attributedBody.string as NSString

        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.font] = Fonts.DMSans.medium.make(15).uiFont

        texts.forEach { text in
            let range = body.range(of: text)

            attributedBody.addAttributes(
                attributes,
                range: range
            )
        }
    }
}

extension AsaVerificationInfoScreen {
    @objc
    private func cancel() {
        eventHandler?(.cancel)
    }

    @objc
    private func performPrimaryAction() {
        open(AlgorandWeb.asaVerificationSupport.link)
    }
}

enum AsaVerificationInfoEvent {
    case cancel
}
