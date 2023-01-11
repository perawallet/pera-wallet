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

//   TitledToggleLoadingView.swift

import MacaroonUIKit
import UIKit

final class TitledToggleLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var titleView = ShimmerView()
    private lazy var toggleView = ShimmerView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        linkInteractors()
    }

    func customize(_ theme: TitledToggleLoadingViewTheme) {
        addTitle(theme)
        addToggle(theme)
    }

    func linkInteractors() {
        isUserInteractionEnabled = false
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension TitledToggleLoadingView {
    private func addTitle(_ theme: TitledToggleLoadingViewTheme) {
        titleView.draw(corner: theme.corner)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.centerY == 0
            $0.top >= 0
            $0.leading == theme.horizontalPadding
            $0.bottom <= 0
            $0.fitToSize(theme.titleSize)
        }
    }

    private func addToggle(_ theme: TitledToggleLoadingViewTheme) {
        toggleView.draw(corner: theme.corner)

        addSubview(toggleView)
        toggleView.snp.makeConstraints {
            $0.centerY == 0
            $0.top >= 0
            $0.bottom <= 0
            $0.trailing == theme.horizontalPadding
            $0.fitToSize(theme.toggleSize)
        }
    }
}
