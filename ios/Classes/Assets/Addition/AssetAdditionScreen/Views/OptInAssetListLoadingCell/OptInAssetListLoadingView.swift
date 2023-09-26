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

//   OptInAssetListLoadingVIew.swift

import Foundation
import MacaroonUIKit
import UIKit

final class OptInAssetListLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    var animatableSubviews: [ShimmerAnimatable] {
        let assetViews = assetsView.arrangedSubviews as! [ShimmerAnimationDisplaying]
        return assetViews.reduce([]) { $0 + $1.animatableSubviews }
    }

    private lazy var assetsView = VStackView()

    init(_ theme: OptInAssetListLoadingViewTheme = .init()) {
        super.init(frame: .zero)
        addUI(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension OptInAssetListLoadingView {
    static func calculatePreferredSize(
        for theme: OptInAssetListLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let height = theme.assetHeight * CGFloat(theme.numberOfAssets)
        return .init(width: width, height: height)
    }
}

extension OptInAssetListLoadingView {
    private func addUI(_ theme: OptInAssetListLoadingViewTheme) {
        addAssets(theme)
    }

    private func addAssets(_ theme: OptInAssetListLoadingViewTheme) {
        addSubview(assetsView)
        assetsView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        (1...theme.numberOfAssets).forEach { i in
            let view = ManageAssetListItemLoadingView()
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
