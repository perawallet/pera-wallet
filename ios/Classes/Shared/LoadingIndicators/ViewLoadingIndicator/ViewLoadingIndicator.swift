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
//   ViewLoadingIndicator.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ViewLoadingIndicator:
    BaseView,
    MacaroonUIKit.LoadingIndicator {
    var isAnimating: Bool {
        return indicatorView.layer.animation(forKey: loadingAnimationKey) != nil
    }

    private lazy var loadingAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = 2 * CGFloat.pi
        animation.duration = 1
        animation.repeatCount = .greatestFiniteMagnitude
        return animation
    }()

    private let indicatorView: UIImageView

    private let loadingAnimationKey = "viewLoadingIndicator.loadingAnimation"

    init(indicator: UIImage?) {
        self.indicatorView = UIImageView(image: indicator)

        super.init(frame: .zero)

        addIndicator()
    }

    convenience init() {
        self.init(indicator: img("loading-indicator"))
    }

    func applyStyle(
        _ style: ImageStyle
    ) {
        backgroundColor = .clear

        indicatorView.customizeAppearance(style)
    }
}

extension ViewLoadingIndicator {
    func startAnimating() {
        if isAnimating {
            return
        }

        indicatorView.layer.add(
            loadingAnimation, forKey: loadingAnimationKey
        )
    }

    func stopAnimating() {
        if !isAnimating {
            return
        }

        indicatorView.layer.removeAnimation(
            forKey: loadingAnimationKey
        )
    }
}

extension ViewLoadingIndicator {
    private func addIndicator() {
        addSubview(indicatorView)
        indicatorView.fitToIntrinsicSize()
        indicatorView.snp.makeConstraints {
            $0.centerHorizontally(
                offset: 0,
                verticalPaddings: (0, 0)
            )
        }
    }
}
