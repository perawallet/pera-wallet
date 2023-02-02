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

//   CollectibleGridItemView.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class CollectibleGridItemView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var imageView = URLImageView()
    private lazy var overlayView = UIImageView()
    private lazy var titleAndSubtitleContentView = MacaroonUIKit.BaseView()
    private lazy var titleView = UILabel()
    private lazy var subtitleView = UILabel()
    private lazy var topLeftBadgeCanvasView = UIImageView()
    private lazy var topLeftBadgeView = UIImageView()
    private lazy var bottomLeftBadgeCanvasView = UIImageView()
    private lazy var bottomLeftBadgeView = UIImageView()
    private lazy var amountCanvasView = UIImageView()
    private lazy var amountView = UILabel()

    private lazy var pendingOverlayView = UIImageView()
    private lazy var pendingCanvasView = UIImageView()
    private lazy var pendingLoadingIndicatorView = ViewLoadingIndicator()
    private lazy var pendingTitleView = UILabel()

    var currentImage: UIImage? {
        return imageView.imageContainer.image
    }
    
    func customize(
        _ theme: CollectibleGridItemViewTheme
    ) {
        addImage(theme)
        addTitleAndSubtitleContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: CollectibleGridItemViewModel?
    ) {
        imageView.load(from: viewModel?.image)
        overlayView.image = viewModel?.overlay
        amountCanvasView.image = viewModel?.amountCanvas
        titleView.editText = viewModel?.title
        subtitleView.editText = viewModel?.subtitle
        topLeftBadgeView.image = viewModel?.topLeftBadge
        topLeftBadgeCanvasView.image =  viewModel?.topLeftBadgeCanvas
        bottomLeftBadgeView.image = viewModel?.bottomLeftBadge
        bottomLeftBadgeCanvasView.image = viewModel?.bottomLeftBadgeCanvas
        amountView.editText = viewModel?.amount
        pendingTitleView.editText = viewModel?.pendingTitle
    }

    func prepareForReuse() {
        imageView.prepareForReuse()
        overlayView.image = nil
        titleView.editText = nil
        subtitleView.editText = nil
        topLeftBadgeView.image = nil
        topLeftBadgeCanvasView.image = nil
        bottomLeftBadgeView.image = nil
        bottomLeftBadgeCanvasView.image = nil
        amountView.editText = nil
        amountCanvasView.image = nil
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleGridItemViewModel?,
        for theme: CollectibleGridItemViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }
        let width = size.width

        let iconHeight = width
        let titleSize =
            viewModel.title.boundingSize(
                multiline: false,
                fittingSize: CGSize((size.width, .greatestFiniteMagnitude))
            )

        let subtitleSingleLineSize =
            viewModel.subtitle.boundingSize(
                multiline: false,
                fittingSize: CGSize((.greatestFiniteMagnitude, .greatestFiniteMagnitude))
            )
        let subtitleHeight: CGFloat

        if subtitleSingleLineSize.width.ceil() > width {
            subtitleHeight = subtitleSingleLineSize.height * 2
        } else {
            subtitleHeight = subtitleSingleLineSize.height
        }

        let preferredHeight =
        iconHeight +
        theme.titleAndSubtitleContentTopPadding +
        titleSize.height +
        subtitleHeight

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CollectibleGridItemView {
    private func addImage(
        _ theme: CollectibleGridItemViewTheme
    ) {
        imageView.build(theme.image)

        addSubview(imageView)
        imageView.fitToIntrinsicSize()
        imageView.snp.makeConstraints {
            $0.width == snp.width
            $0.height == imageView.snp.width

            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        addOverlay(theme)
        addPendingOverlayView(theme)
        addBottomLeftBadge(theme)
        addTopLeftBadge(theme)
        addAmount(theme)
    }

    private func addOverlay(
        _ theme: CollectibleGridItemViewTheme
    ) {
        imageView.addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addTitleAndSubtitleContent(
        _ theme: CollectibleGridItemViewTheme
    ) {
        addSubview(titleAndSubtitleContentView)
        titleAndSubtitleContentView.snp.makeConstraints {
            $0.top == imageView.snp.bottom + theme.titleAndSubtitleContentTopPadding
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addTitle(theme)
        addSubtitle(theme)
    }

    private func addTitle(
        _ theme: CollectibleGridItemViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        titleAndSubtitleContentView.addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addSubtitle(
        _ theme: CollectibleGridItemViewTheme
    ) {
        subtitleView.customizeAppearance(theme.subtitle)

        titleAndSubtitleContentView.addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addBottomLeftBadge(
        _ theme: CollectibleGridItemViewTheme
    ) {
        addSubview(bottomLeftBadgeCanvasView)
        bottomLeftBadgeCanvasView.snp.makeConstraints {
            $0.leading == theme.bottomLeftBadgePaddings.leading
            $0.bottom == imageView.snp.bottom - theme.bottomLeftBadgePaddings.bottom
        }

        bottomLeftBadgeView.customizeAppearance(theme.bottomLeftBadge)

        bottomLeftBadgeCanvasView.addSubview(bottomLeftBadgeView)
        bottomLeftBadgeView.snp.makeConstraints {
            $0.top == theme.bottomLeftBadgeContentEdgeInsets.top
            $0.leading == theme.bottomLeftBadgeContentEdgeInsets.leading
            $0.bottom == theme.bottomLeftBadgeContentEdgeInsets.bottom
            $0.trailing == theme.bottomLeftBadgeContentEdgeInsets.trailing
        }
    }

    private func addPendingOverlayView(
        _ theme: CollectibleGridItemViewTheme
    ) {
        pendingOverlayView.customizeAppearance(theme.pendingOverlay)

        imageView.addSubview(pendingOverlayView)
        pendingOverlayView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addPendingCanvasView(theme)

        setPendingHiddenWhenPendingStatusChange(false)
    }

    private func addPendingCanvasView(
        _ theme: CollectibleGridItemViewTheme
    ) {
        pendingCanvasView.customizeAppearance(theme.pendingCanvas)

        pendingOverlayView.addSubview(pendingCanvasView)
        pendingCanvasView.snp.makeConstraints {
            $0.leading == theme.pendingCanvasPaddings.leading
            $0.bottom == theme.pendingCanvasPaddings.bottom
            $0.trailing <= theme.pendingCanvasPaddings.leading
        }

        addPendingLoadingIndicator(theme)
        addPendingTitle(theme)
    }

    private func addPendingLoadingIndicator(
        _ theme: CollectibleGridItemViewTheme
    ) {
        pendingLoadingIndicatorView.applyStyle(theme.indicator)

        pendingCanvasView.addSubview(pendingLoadingIndicatorView)
        pendingLoadingIndicatorView.fitToIntrinsicSize()
        pendingLoadingIndicatorView.snp.makeConstraints {
            $0.fitToSize(theme.indicatorSize)
            $0.leading == theme.indicatorLeadingPadding
            $0.centerY == 0
        }
    }

    private func addPendingTitle(
        _ theme: CollectibleGridItemViewTheme
    ) {
        pendingTitleView.customizeAppearance(theme.pendingTitle)

        pendingCanvasView.addSubview(pendingTitleView)
        pendingTitleView.snp.makeConstraints {
            $0.top == theme.pendingTitlePaddings.top
            $0.leading == pendingLoadingIndicatorView.snp.trailing + theme.pendingTitlePaddings.leading
            $0.bottom == theme.pendingTitlePaddings.bottom
            $0.trailing == theme.pendingTitlePaddings.trailing
        }
    }

    private func addTopLeftBadge(
        _ theme: CollectibleGridItemViewTheme
    ) {
        addSubview(topLeftBadgeCanvasView)
        topLeftBadgeCanvasView.snp.makeConstraints {
            $0.leading == theme.topLeftBadgePaddings.leading
            $0.top == theme.topLeftBadgePaddings.top
        }

        topLeftBadgeView.customizeAppearance(theme.topLeftBadge)

        topLeftBadgeView.fitToHorizontalIntrinsicSize()
        topLeftBadgeCanvasView.addSubview(topLeftBadgeView)
        topLeftBadgeView.snp.makeConstraints {
            $0.top == theme.topLeftBadgeContentEdgeInsets.top
            $0.leading == theme.topLeftBadgeContentEdgeInsets.leading
            $0.bottom == theme.topLeftBadgeContentEdgeInsets.bottom
            $0.trailing == theme.topLeftBadgeContentEdgeInsets.trailing
        }
    }

    private func addAmount(
        _ theme: CollectibleGridItemViewTheme
    ) {
        addSubview(amountCanvasView)
        amountCanvasView.snp.makeConstraints {
            $0.top == theme.amountPaddings.top
            $0.leading >= topLeftBadgeView.snp.trailing + theme.minimumSpacingBetweeenTopLeftBadgeAndAmount
            $0.trailing == theme.amountPaddings.trailing
        }

        amountView.customizeAppearance(theme.amount)

        amountCanvasView.addSubview(amountView)
        amountView.snp.makeConstraints {
            $0.top == theme.amountContentEdgeInsets.top
            $0.leading == theme.amountContentEdgeInsets.leading
            $0.bottom == theme.amountContentEdgeInsets.bottom
            $0.trailing == theme.amountContentEdgeInsets.trailing
        }
    }
}

extension CollectibleGridItemView {
    func getTargetedPreview() -> UITargetedPreview {
        return UITargetedPreview(
            view: imageView.imageContainer,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }
}

extension CollectibleGridItemView {
    var isLoading: Bool {
        return pendingLoadingIndicatorView.isAnimating
    }

    func startLoading() {
        setPendingHiddenWhenPendingStatusChange(true)
    }

    func stopLoading() {
        setPendingHiddenWhenPendingStatusChange(false)
    }
    
    private func setPendingHiddenWhenPendingStatusChange(_ isPending: Bool) {
        pendingOverlayView.isHidden = !isPending
        overlayView.isHidden = isPending
        bottomLeftBadgeCanvasView.isHidden = isPending
        
        if isPending {
            pendingLoadingIndicatorView.startAnimating()
        } else {
            pendingLoadingIndicatorView.stopAnimating()
        }
    }
}
