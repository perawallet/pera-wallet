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

//   LogoLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class LogoLoadingView: MacaroonUIKit.BaseView {
    var isAnimating: Bool { logoView.isAnimationPlaying }

    private lazy var logoView: LottieImageView = .init()

    init(_ style: Style) {
        super.init(frame: .zero)
        addUI(style)
    }
}

extension LogoLoadingView {
    func startAnimating() {
        if isAnimating { return }
        logoView.play(with: .init())
    }

    func stopAnimating() {
        if !isAnimating { return }
        logoView.stop()
    }
}

extension LogoLoadingView {
    private func addUI(_ style: Style) {
        addLogo(style)
    }

    private func addLogo(_ style: Style) {
        addSubview(logoView)
        logoView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        if let animation = findLogoAnimation(for: style) {
            logoView.setAnimation(animation)
        }
    }

    private func findLogoAnimation(for style: Style) -> String? {
        let root: String
        switch style {
        case .purple: root = "pera-loader-purple"
        }

        let suffix: String
        switch traitCollection.userInterfaceStyle {
        case .dark: suffix = "dark"
        default: suffix = "light"
        }

        return root + "-" + suffix
    }
}

extension LogoLoadingView {
    enum Style {
        case purple
    }
}
