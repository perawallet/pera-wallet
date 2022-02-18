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
//  PasswordInputView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class PasswordInputView: View {
    private lazy var theme = PasswordInputViewTheme()

    var shakeConfiguration = ShakeConfiguration()
    
    private(set) var passwordInputCircleViews: [PasswordInputCircleView] = []
    private lazy var stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }

    func customize(_ theme: PasswordInputViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addStackView(theme)
        addCircleViews()
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension PasswordInputView {
    private func addStackView(_ theme: PasswordInputViewTheme) {
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = theme.stackViewSpacing

        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func addCircleViews() {
        for _ in 1...6 {
            let circleView = PasswordInputCircleView(frame: .zero)
            passwordInputCircleViews.append(circleView)
            stackView.addArrangedSubview(circleView)
        }
    }
}

extension PasswordInputView {
    struct ShakeConfiguration {
        let keyPath = "position"
        let duration = 0.07
        let repeatCount: Float = 4
        let autoReverses = true
        let offsetChange = 10.0

        var totalDuration: Double {
            Double(repeatCount) * duration * 2
        }
    }

    func shake(then handler: @escaping EmptyHandler) {
        let animation = CABasicAnimation(keyPath: shakeConfiguration.keyPath)
        animation.duration = shakeConfiguration.duration
        animation.repeatCount = shakeConfiguration.repeatCount
        animation.autoreverses = shakeConfiguration.autoReverses
        animation.fromValue = NSValue(
            cgPoint: CGPoint(x: center.x - shakeConfiguration.offsetChange, y: center.y)
        )
        animation.toValue = NSValue(
            cgPoint: CGPoint(x: center.x + shakeConfiguration.offsetChange, y: center.y)
        )
        self.layer.add(animation, forKey: shakeConfiguration.keyPath)

        asyncMain(
            afterDuration: shakeConfiguration.totalDuration
        ) {
            handler()
        }
    }

    func changeStateTo(_ state: PasswordInputCircleView.State) {
        for view in passwordInputCircleViews {
            view.state = state
        }
    }
}
