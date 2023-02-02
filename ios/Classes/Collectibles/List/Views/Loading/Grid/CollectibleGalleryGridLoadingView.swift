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

//   CollectibleGalleryGridLoadingView.swift

import UIKit
import MacaroonUIKit

final class CollectibleGalleryGridLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var assetsView = VStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = false
    }

    func customize(_ theme: CollectibleGalleryGridLoadingViewTheme) {
        addUI(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    class func calculatePreferredSize(
        for theme: CollectibleGalleryGridLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width

        let rowCount = theme.assetsRowCount
        let columnCount = theme.assetColumnCount

        let rowSpacing = theme.assetHorizontalSpacing
        let assetWidth = (width - rowSpacing) / columnCount.cgFloat

        let assetHeight =  CollectibleGridItemLoadingView.calculatePreferredSize(
            for: theme.asset,
            fittingIn: CGSize((assetWidth.float(), size.height))
        )

        let assetsHeight = assetHeight.height * rowCount.cgFloat
        let assetsSpacing = theme.assetVerticalSpacing * (rowCount.cgFloat - 1)
        let preferredHeight = assetsHeight + assetsSpacing

        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CollectibleGalleryGridLoadingView {
    private func addUI(_ theme: CollectibleGalleryGridLoadingViewTheme) {
        addAssets(theme)
    }

    private func addAssets(_ theme: CollectibleGalleryGridLoadingViewTheme) {
        addSubview(assetsView)
        assetsView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }

        assetsView.spacing = theme.assetVerticalSpacing
        assetsView.distribution = .equalSpacing

        (0..<theme.assetsRowCount).forEach { _ in
            let assetHorizontalStack = UIStackView()
            assetHorizontalStack.spacing = theme.assetHorizontalSpacing
            assetHorizontalStack.distribution = .fillEqually

            (0..<theme.assetColumnCount).forEach { _ in
                let view = CollectibleGridItemLoadingView()
                view.customize(theme.asset)
                assetHorizontalStack.addArrangedSubview(view)
            }

            assetsView.addArrangedSubview(assetHorizontalStack)
        }
    }
}
