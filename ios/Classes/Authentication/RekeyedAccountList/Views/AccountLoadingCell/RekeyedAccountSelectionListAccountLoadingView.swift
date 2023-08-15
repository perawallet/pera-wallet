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

//   RekeyedAccountSelectionListAccountLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class RekeyedAccountSelectionListAccountLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    var animatableSubviews: [ShimmerAnimatable] {
        let accountsView = accountsView.arrangedSubviews as! [ShimmerAnimationDisplaying]
        return accountsView.reduce([]) { $0 + $1.animatableSubviews }
    }

    private lazy var accountsView = VStackView()

    init(_ theme: RekeyedAccountSelectionListAccountLoadingViewTheme = .init()) {
        super.init(frame: .zero)
        addUI(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension RekeyedAccountSelectionListAccountLoadingView {
    static func calculatePreferredSize(
        for theme: RekeyedAccountSelectionListAccountLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let height = theme.accountHeight * CGFloat(theme.numberOfAccounts)
        return .init(width: width, height: height)
    }
}

extension RekeyedAccountSelectionListAccountLoadingView {
    private func addUI(_ theme: RekeyedAccountSelectionListAccountLoadingViewTheme) {
        addAccounts(theme)
    }

    private func addAccounts(_ theme: RekeyedAccountSelectionListAccountLoadingViewTheme) {
        accountsView.spacing = theme.spacingBetweenItems

        addSubview(accountsView)
        accountsView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        (1...theme.numberOfAccounts).forEach { _ in
            let view = RekeyedAccountSelectionListAccountLoadingItemView()
            view.customize(theme.account)
            view.snp.makeConstraints {
                $0.fitToHeight(theme.accountHeight)
            }
            accountsView.addArrangedSubview(view)
        }
    }
}
