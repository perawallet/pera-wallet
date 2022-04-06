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

//   CollectibleListItemPendingView.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class CollectibleListItemPendingView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var image = URLImageView()
    private lazy var overlay = MacaroonUIKit.BaseView()
    private lazy var titleAndSubtitleContentView = MacaroonUIKit.BaseView()
    private lazy var title = Label()
    private lazy var subtitle = Label()
    private lazy var topLeftBadge = ImageView()
    private lazy var pendingContentView = UIView()
    private lazy var pendingLoadingIndicator = ViewLoadingIndicator()
    private lazy var pendingLabel = Label()

    func customize(
        _ theme: CollectibleListItemPendingViewTheme
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
        _ viewModel: CollectibleListItemPendingViewModel?
    ) {
        image.load(from: viewModel?.image)
        title.editText = viewModel?.title
        subtitle.editText = viewModel?.subtitle
        topLeftBadge.image = viewModel?.topLeftBadge
        pendingLabel.editText = viewModel?.pendingTitle
    }

    func prepareForReuse() {
        stopLoading()
        image.prepareForReuse()
        title.editText = nil
        subtitle.editText = nil
        topLeftBadge.image = nil
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleListItemPendingViewModel?,
        for theme: CollectibleListItemPendingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let iconHeight = size.width
        let titleSize =
            viewModel.title.boundingSize(
                fittingSize: CGSize((size.width, .greatestFiniteMagnitude))
            )
        let bodySize =
            viewModel.subtitle.boundingSize(
                fittingSize: CGSize((size.width, .greatestFiniteMagnitude))
            )
        let preferredHeight =
        iconHeight +
        theme.titleAndSubtitleContentTopPadding +
        titleSize.height +
        bodySize.height

        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CollectibleListItemPendingView {
    private func addImage(
        _ theme: CollectibleListItemPendingViewTheme
    ) {
        image.customizeAppearance(theme.image)
        image.layer.draw(corner: theme.corner)
        image.clipsToBounds = true

        addSubview(image)
        image.fitToIntrinsicSize()
        image.snp.makeConstraints {
            $0.width == snp.width
            $0.height == image.snp.width

            $0.setPaddings((0, 0, .noMetric, 0))
        }

        addOverlay(theme)
        addTopLeftBadge(theme)
        addPendingContentView(theme)
    }

    private func addOverlay(
        _ theme: CollectibleListItemPendingViewTheme
    ) {
        overlay.customizeAppearance(theme.overlay)
        overlay.alpha = theme.overlayAlpha

        image.addSubview(overlay)
        overlay.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addTitleAndSubtitleContent(
        _ theme: CollectibleListItemPendingViewTheme
    ) {
        addSubview(titleAndSubtitleContentView)
        titleAndSubtitleContentView.snp.makeConstraints {
            $0.top == image.snp.bottom + theme.titleAndSubtitleContentTopPadding
            $0.setPaddings((.noMetric, 0, 0, 0))
        }

        addTitle(theme)
        addSubtitle(theme)
    }

    private func addTitle(
        _ theme: CollectibleListItemPendingViewTheme
    ) {
        title.customizeAppearance(theme.title)

        titleAndSubtitleContentView.addSubview(title)
        title.fitToIntrinsicSize()
        title.snp.makeConstraints {
            $0.setPaddings((0, 0, .noMetric, 0))
        }
    }

    private func addSubtitle(
        _ theme: CollectibleListItemPendingViewTheme
    ) {
        subtitle.customizeAppearance(theme.subtitle)

        titleAndSubtitleContentView.addSubview(subtitle)
        subtitle.snp.makeConstraints {
            $0.top == title.snp.bottom

            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }

    private func addPendingContentView(
        _ theme: CollectibleListItemPendingViewTheme
    ) {
        pendingContentView.customizeAppearance(theme.pendingContent)
        pendingContentView.layer.draw(corner: theme.corner)
        pendingContentView.layer.draw(
            border: Border(
                color: AppColors.SendTransaction.Shadow.first.uiColor,
                width: 1
            )
        ) /// <todo> Add proper shadow when shadow & borders are refactored.

        addSubview(pendingContentView)
        pendingContentView.snp.makeConstraints {
            $0.leading == theme.pendingContentPaddings.leading
            $0.bottom == image.snp.bottom - theme.pendingContentPaddings.bottom
            $0.trailing <= theme.pendingContentPaddings.leading
        }

        addPendingLoadingIndicator(theme)
        addPendingLabel(theme)
    }

    private func addPendingLoadingIndicator(
        _ theme: CollectibleListItemPendingViewTheme
    ) {
        pendingLoadingIndicator.applyStyle(theme.indicator)

        pendingContentView.addSubview(pendingLoadingIndicator)
        pendingLoadingIndicator.fitToIntrinsicSize()
        pendingLoadingIndicator.snp.makeConstraints {
            $0.fitToSize(theme.indicatorSize)
            $0.leading == theme.indicatorLeadingPadding
            $0.centerY == 0
        }
    }

    private func addPendingLabel(
        _ theme: CollectibleListItemPendingViewTheme
    ) {
        pendingLabel.customizeAppearance(theme.pendingLabel)

        pendingContentView.addSubview(pendingLabel)
        pendingLabel.snp.makeConstraints {
            $0.top == theme.pendingLabelPaddings.top
            $0.leading == pendingLoadingIndicator.snp.trailing + theme.pendingLabelPaddings.leading
            $0.bottom == theme.pendingLabelPaddings.bottom
            $0.trailing == theme.pendingLabelPaddings.trailing
        }
    }

    private func addTopLeftBadge(
        _ theme: CollectibleListItemPendingViewTheme
    ) {
        topLeftBadge.customizeAppearance(theme.topLeftBadge)
        topLeftBadge.layer.draw(corner: theme.corner)

        topLeftBadge.contentEdgeInsets = theme.topLeftBadgeContentEdgeInsets
        addSubview(topLeftBadge)
        topLeftBadge.snp.makeConstraints {
            $0.leading == theme.topLeftBadgePaddings.leading
            $0.top == theme.topLeftBadgePaddings.top
        }
    }
}

extension CollectibleListItemPendingView {
    func startLoading() {
        pendingLoadingIndicator.startAnimating()
    }

    func stopLoading() {
        pendingLoadingIndicator.stopAnimating()
    }
}
