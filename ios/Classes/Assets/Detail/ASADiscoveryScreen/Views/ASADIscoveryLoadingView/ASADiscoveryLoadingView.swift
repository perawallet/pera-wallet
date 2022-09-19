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

//   ASADiscoveryLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ASADiscoveryLoadingView:
    UIView,
    ShimmerAnimationDisplaying {
    private lazy var profileView = UIView()
    private lazy var iconView = ShimmerView()
    private lazy var titleView = ShimmerView()
    private lazy var valueView = ShimmerView()
    private lazy var aboutView = ASAAboutLoadingView()

    func customize(_ theme: ASADiscoveryLoadingViewTheme) {
        addBackground(theme)
        addProfile(theme)
        addAbout(theme)
    }
}

extension ASADiscoveryLoadingView {
    private func addBackground(_ theme: ASADiscoveryLoadingViewTheme) {
        customizeAppearance(theme.background)
    }

    private func addProfile(_ theme: ASADiscoveryLoadingViewTheme) {
        profileView.customizeAppearance(theme.profile)

        addSubview(profileView)
        profileView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        addIcon(theme)
        addTitle(theme)
        addValue(theme)
    }

    private func addIcon(_ theme: ASADiscoveryLoadingViewTheme) {
        iconView.draw(corner: theme.iconCorner)

        profileView.addSubview(iconView)
        iconView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.top == theme.profileContentEdgeInsets.top
            $0.centerX == 0
        }
    }

    private func addTitle(_ theme: ASADiscoveryLoadingViewTheme) {
        titleView.draw(corner: theme.corner)

        profileView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.fitToSize(theme.titleSize)
            $0.top == iconView.snp.bottom + theme.spacingBetweenIconAndTitle
            $0.centerX == 0
        }
    }

    private func addValue(_ theme: ASADiscoveryLoadingViewTheme) {
        valueView.draw(corner: theme.corner)

        profileView.addSubview(valueView)
        valueView.snp.makeConstraints {
            $0.fitToSize(theme.valueSize)
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndValue
            $0.bottom == theme.profileContentEdgeInsets.bottom
            $0.centerX == 0
        }
    }

    private func addAbout(_ theme: ASADiscoveryLoadingViewTheme) {
        aboutView.customize(theme.about)

        addSubview(aboutView)
        aboutView.snp.makeConstraints {
            $0.top == profileView.snp.bottom
            $0.leading == 0
            $0.trailing == 0
        }
    }
}
