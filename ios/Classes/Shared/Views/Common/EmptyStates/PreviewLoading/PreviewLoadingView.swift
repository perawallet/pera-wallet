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
//   PreviewLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class PreviewLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var imageView = ShimmerView()
    private lazy var titleView = ShimmerView()
    private lazy var subtitleView = ShimmerView()
    private lazy var supplementaryView = ShimmerView()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        linkInteractors()
    }

    func customize(
        _ theme: PreviewLoadingViewTheme
    ) {
        addImageView(theme)
        addTitleView(theme)
        addSubtitleView(theme)
        addSupplementaryView(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func linkInteractors() {
        isUserInteractionEnabled = false
    }

    class func calculatePreferredSize(
        for theme: PreviewLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let titleHeight =
            theme.titleViewSize.h +
            theme.titleMargin.top
        let subtitleHeight =
            theme.subtitleViewSize.h +
            theme.subtitleMargin.top +
            theme.subtitleMargin.bottom
        let supplementaryHeight = theme.supplementaryViewSize.h
        let imageHeight = theme.imageViewSize.h

        let textContentHeight = titleHeight + subtitleHeight
        let contentHeight = max(textContentHeight.ceil(), supplementaryHeight.ceil())
        let preferredHeight = max(imageHeight.ceil(), contentHeight)

        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}

extension PreviewLoadingView {
    private func addImageView(_ theme: PreviewLoadingViewTheme) {
        imageView.draw(corner: Corner(radius: theme.imageViewCorner))
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(
                CGSize(width: theme.imageViewSize.w,
                       height: theme.imageViewSize.h)
            )
        }
    }

    private func addTitleView(_ theme: PreviewLoadingViewTheme) {
        titleView.draw(corner: Corner(radius: theme.titleViewCorner))

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.titleMargin.leading)
            $0.top.equalToSuperview().inset(theme.titleMargin.top)
            $0.size.equalTo(
                CGSize(width: theme.titleViewSize.w,
                       height: theme.titleViewSize.h)
            )
        }
    }

    private func addSubtitleView(_ theme: PreviewLoadingViewTheme) {
        subtitleView.draw(corner: Corner(radius: theme.subtitleViewCorner))

        addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.subtitleMargin.leading)
            $0.top.equalTo(titleView.snp.bottom).offset(theme.subtitleMargin.top)
            $0.size.equalTo(
                CGSize(width: theme.subtitleViewSize.w,
                       height: theme.subtitleViewSize.h)
            )
        }
    }

    private func addSupplementaryView(_ theme: PreviewLoadingViewTheme) {
        supplementaryView.draw(corner: Corner(radius: theme.supplementaryViewCorner))

        addSubview(supplementaryView)
        supplementaryView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(
                CGSize(width: theme.supplementaryViewSize.w,
                       height: theme.supplementaryViewSize.h)
            )
        }
    }
}
