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

//   SendCollectibleView.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class SendCollectibleView:
    View,
    ViewModelBindable {
    var imageSize: CGSize {
        imageView.frame.size
    }

    private(set) lazy var contextViewContainer = MacaroonUIKit.BaseView()
    private lazy var contextView = MacaroonUIKit.BaseView()
    private(set) lazy var imageView = URLImageView()
    private lazy var titleAndSubtitleContainer = MacaroonUIKit.BaseView()
    private lazy var titleView = Label()
    private lazy var subtitleView = Label()
    private(set) lazy var actionView = SendCollectibleActionView()

    func customize(
        _ theme: SendCollectibleViewTheme
    ) {
        addContext(theme)
        addAction(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: SendCollectibleViewModel?
    ) {
        guard let viewModel = viewModel else {
            return
        }

        if let image = viewModel.existingImage {
            imageView.imageContainer.image = image
        } else {
            imageView.load(from: viewModel.image)
        }

        titleView.editText = viewModel.title
        subtitleView.editText = viewModel.subtitle
    }
}

extension SendCollectibleView {
    private func addContext(
        _ theme: SendCollectibleViewTheme
    ) {
        addSubview(contextViewContainer)
        contextViewContainer.snp.makeConstraints {
            $0.top == theme.contextViewContainerTopPadding
            $0.setPaddings(
                (.noMetric, theme.horizontalPadding, .noMetric, theme.horizontalPadding)
            )
        }

        contextViewContainer.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top >= 0
            $0.bottom == 0
            $0.trailing == 0
            $0.leading == 0
            $0.center == 0
        }

        addImage(theme)
        addTitleAndSubtitleContainer(theme)
    }


    private func addTitleAndSubtitleContainer(
        _ theme: SendCollectibleViewTheme
    ) {
        let aCanvasView = MacaroonUIKit.BaseView()

        contextView.addSubview(aCanvasView)
        aCanvasView.snp.makeConstraints {
            $0.top == imageView.snp.bottom
            $0.centerX == 0
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }

        aCanvasView.addSubview(titleAndSubtitleContainer)
        titleAndSubtitleContainer.snp.makeConstraints {
            $0.top >= theme.titleAndSubtitleContainerVerticalPaddings.top
            $0.bottom <= theme.titleAndSubtitleContainerVerticalPaddings.bottom
            $0.center == 0

            $0.setPaddings((.noMetric, 0, .noMetric, 0))
        }

        addTitle(theme)
        addSubtitle(theme)
    }

    private func addTitle(
        _ theme: SendCollectibleViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        titleAndSubtitleContainer.addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.setPaddings((0, 0, .noMetric, 0))
        }
    }

    private func addSubtitle(
        _ theme: SendCollectibleViewTheme
    ) {
        subtitleView.customizeAppearance(theme.subtitle)

        subtitleView.contentEdgeInsets.top = theme.subtitleTopPadding
        subtitleView.fitToIntrinsicSize()
        titleAndSubtitleContainer.addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom

            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }

    private func addImage(
        _ theme: SendCollectibleViewTheme
    ) {
        imageView.build(theme.image)
        imageView.draw(corner: theme.imageCorner)

        contextView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == 0
            $0.leading == theme.horizontalPadding
            $0.trailing == theme.horizontalPadding
            $0.height == imageView.snp.width
        }
    }

    private func addAction(
        _ theme: SendCollectibleViewTheme
    ) {
        actionView.customize(theme.actionViewTheme)

        addSubview(actionView)
        actionView.fitToIntrinsicSize()
        actionView.snp.makeConstraints {
            $0.top == contextViewContainer.snp.bottom

            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }
}
