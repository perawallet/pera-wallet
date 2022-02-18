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

//   PeraIntroductionView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class PeraIntroductionView:
    View,
    ViewModelBindable,
    UIInteractionObservable,
    UIControlInteractionPublisher {
    weak var delegate: PeraIntroductionViewDelegate? /// <todo> Remove delegate

    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .closeScreen: UIControlInteraction()
    ]

    private lazy var theme = PeraInroductionViewTheme()

    private lazy var closeButton = UIButton()

    private lazy var topViewContainer = UIView()
    private lazy var peraLogoImageView = ImageView()
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private lazy var titleLabel = Label()
    private lazy var subtitleLabel = Label()
    private lazy var descriptionLabel = Label()
    private lazy var actionButtonContainer = UIView()
    private lazy var actionButton = MacaroonUIKit.Button()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        linkInteractors()
    }

    private var isLayoutFinalized = false

    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.isEmpty {
            return
        }

        if !isLayoutFinalized {
            isLayoutFinalized = true

            addLinearGradient()
        }
    }

    func customize(
        _ theme: PeraInroductionViewTheme
    ) {
        self.theme = theme

        addScrollView(theme)
        addContentView()
        addTitleLabel(theme)
        addSubtitleLabel(theme)
        addDescriptionLabel(theme)
        addActionButton(theme)
        addTopViewContainer(theme)
        addPeraAlgoImageView(theme)
        addCloseButton(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) { }

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) { }

    func bindData(
        _ viewModel: PeraIntroductionViewModel?
    ) {
        peraLogoImageView.image = viewModel?.logoImage?.uiImage
        titleLabel.editText = viewModel?.title
        subtitleLabel.editText = viewModel?.subtitle
        descriptionLabel.editText = viewModel?.description
    }

    func linkInteractors() {
        scrollView.delegate = self

        startPublishing(event: .closeScreen, for: closeButton)
        startPublishing(event: .closeScreen, for: actionButton)

        descriptionLabel.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(didTapDescriptionLabel)
            )
        )
    }
}

extension PeraIntroductionView {
    private func addCloseButton(
        _ theme: PeraInroductionViewTheme
    ) {
        closeButton.customizeAppearance(theme.closeButton)

        addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.closeButtonTopPadding)
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.fitToSize(theme.closeButtonSize)
        }
    }

    private func addTopViewContainer(
        _ theme: PeraInroductionViewTheme
    ) {
        topViewContainer.customizeAppearance(theme.topViewContainer)

        addSubview(topViewContainer)
        topViewContainer.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.fitToHeight(theme.topContainerMaxHeight)
        }
    }

    private func addPeraAlgoImageView(
        _ theme: PeraInroductionViewTheme
    ) {
        peraLogoImageView.customizeAppearance(theme.peraLogoImageView)

        topViewContainer.addSubview(peraLogoImageView)
        peraLogoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.fitToSize(theme.peraLogoMaxSize)
        }
    }

    private func addScrollView(
        _ theme: PeraInroductionViewTheme
    ) {
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset.top = theme.topContainerMaxHeight

        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addContentView() {
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.edges.equalToSuperview()
        }
    }

    private func addTitleLabel(
        _ theme: PeraInroductionViewTheme
    ) {
        titleLabel.customizeAppearance(theme.titleLabel)

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(theme.titleLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addSubtitleLabel(
        _ theme: PeraInroductionViewTheme
    ) {
        subtitleLabel.customizeAppearance(theme.subtitleLabel)

        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.subtitleLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addDescriptionLabel(
        _ theme: PeraInroductionViewTheme
    ) {
        descriptionLabel.customizeAppearance(theme.descriptionLabel)

        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(theme.descriptionLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.lessThanOrEqualToSuperview().inset(
                theme.descriptionLabelBottomPadding +
                theme.linearGradientHeight +
                safeAreaBottom
            )
        }
    }

    private func addActionButton(
        _ theme: PeraInroductionViewTheme
    ) {
        addSubview(actionButtonContainer)
        actionButtonContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.fitToHeight(theme.linearGradientHeight + safeAreaBottom)
        }

        actionButton.contentEdgeInsets = UIEdgeInsets(theme.actionButtonContentEdgeInsets)
        actionButton.draw(corner: theme.actionButtonCorner)
        actionButton.customizeAppearance(theme.actionButton)

        actionButtonContainer.addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.bottomPadding)
        }
    }

    private func addLinearGradient() {
        let layer = CAGradientLayer()
        layer.frame = CGRect(
            origin: .zero,
            size: CGSize(width: bounds.width, height: theme.linearGradientHeight + safeAreaBottom)
        )

        let color0 = AppColors.Shared.System.background.uiColor.withAlphaComponent(0).cgColor
        let color1 = AppColors.Shared.System.background.uiColor.cgColor

        layer.colors = [color0, color1]
        actionButtonContainer.layer.insertSublayer(layer, at: 0)
    }
}

/// <note>: Parallax effect
extension PeraIntroductionView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentY = scrollView.contentOffset.y + scrollView.contentInset.top

        let height = theme.topContainerMaxHeight - contentY

        if height < theme.topContainerMinHeight {
            return
        }

        topViewContainer.snp.updateConstraints {
            $0.fitToHeight(height)
        }

        peraLogoImageView.snp.updateConstraints {
            $0.fitToSize(
                (
                    max(
                        theme.peraLogoMinSize.w,
                        theme.peraLogoMaxSize.w * height / theme.topContainerMaxHeight
                    ),
                    max(
                        theme.peraLogoMinSize.h,
                        theme.peraLogoMaxSize.h * height / theme.topContainerMaxHeight
                    )
                )
            )
        }
    }
}

extension PeraIntroductionView {
    /// <todo>
    /// We need a component/functionality for better handling texts with links.
    @objc
    private func didTapDescriptionLabel(_ recognizer: UITapGestureRecognizer) {
        let fullText = "pera-announcement-description".localized as NSString
        let peraWalletBlog = fullText.range(of: "pera-announcement-description-blog".localized)

        if recognizer.detectTouchForLabel(descriptionLabel, in: peraWalletBlog) {
            delegate?.peraInroductionViewDidTapPeraWalletBlog(self)
        }
    }
}

extension PeraIntroductionView {
    enum Event {
        case closeScreen
    }
}

protocol PeraIntroductionViewDelegate: AnyObject {
    func peraInroductionViewDidTapPeraWalletBlog(_ peraIntroductionView: PeraIntroductionView)
}
