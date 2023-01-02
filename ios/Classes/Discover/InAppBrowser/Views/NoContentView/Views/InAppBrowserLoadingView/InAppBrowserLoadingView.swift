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

//   InAppBrowserLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class InAppBrowserLoadingView: MacaroonUIKit.BaseView {
    var isAnimating: Bool { logoView.isAnimating }

    private let logoView: LogoLoadingView

    init(_ theme: InAppBrowserLoadingViewTheme = .init()) {
        self.logoView = .init(theme.logoStyle)
        super.init(frame: .zero)

        addUI(theme)
    }
}

extension InAppBrowserLoadingView {
    func startAnimating() {
        logoView.startAnimating()
    }

    func stopAnimating() {
        logoView.stopAnimating()
    }
}

extension InAppBrowserLoadingView {
    private func addUI(_ theme: InAppBrowserLoadingViewTheme) {
        addLogo(theme)
    }

    private func addLogo(_ theme: InAppBrowserLoadingViewTheme) {
        addSubview(logoView)
        logoView.snp.makeConstraints {
            $0.fitToSize((theme.logoSize.width, theme.logoSize.height))
            $0.center == 0
        }
    }
}
