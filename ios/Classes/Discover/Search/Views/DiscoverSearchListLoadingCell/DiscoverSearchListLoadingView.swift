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

//   DiscoverSearchListLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class DiscoverSearchListLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    var animatableSubviews: [ShimmerAnimatable] {
        let assetViews = assetsView.arrangedSubviews as! [ShimmerAnimationDisplaying]
        return assetViews.reduce([]) { $0 + $1.animatableSubviews }
    }

    private lazy var assetsView = VStackView()

    init(_ theme: DiscoverSearchListLoadingViewTheme = .init()) {
        super.init(frame: .zero)
        addUI(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension DiscoverSearchListLoadingView {
    static func calculatePreferredSize(
        for theme: DiscoverSearchListLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let height = theme.assetHeight * CGFloat(theme.numberOfAssets)
        return .init(width: width, height: height)
    }
}

extension DiscoverSearchListLoadingView {
    private func addUI(_ theme: DiscoverSearchListLoadingViewTheme) {
        addAssets(theme)
    }

    private func addAssets(_ theme: DiscoverSearchListLoadingViewTheme) {
        addSubview(assetsView)
        assetsView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
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
