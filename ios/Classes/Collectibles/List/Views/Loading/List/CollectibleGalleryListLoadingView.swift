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

//   CollectibleGalleryListLoadingView.swift

import UIKit
import MacaroonUIKit

final class CollectibleGalleryListLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var assetsView = VStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = false
    }

    func customize(_ theme: CollectibleGalleryListLoadingViewTheme) {
        addUI(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    class func calculatePreferredSize(
        for theme: CollectibleGalleryListLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let height = theme.assetHeight * CGFloat(theme.numberOfAssets)
        return .init(width: width, height: height)
    }
}

extension CollectibleGalleryListLoadingView {
    private func addUI(_ theme: CollectibleGalleryListLoadingViewTheme) {
        addAssets(theme)
    }

    private func addAssets(_ theme: CollectibleGalleryListLoadingViewTheme) {
        addSubview(assetsView)
        assetsView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }

        (1...theme.numberOfAssets).forEach { i in
            let view = PreviewLoadingView()
            view.customize(theme.asset)
            view.snp.makeConstraints {
                $0.fitToHeight(theme.assetHeight)
            }
            assetsView.addArrangedSubview(view)

            if i != theme.numberOfAssets {
                view.addSeparator(theme.assetSeparator)
            }
        }
    }
}
