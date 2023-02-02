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

//   ShimmerAnimatable.swift

import UIKit
import MacaroonUIKit

protocol ShimmerAnimatable {
    var isAnimating: Bool { get }
    
    var configuration: ShimmerAnimationConfiguration { get }

    func startAnimating()
    func stopAnimating()

    func composeAnimationLayer() -> CAGradientLayer
    func composeAnimation() -> CABasicAnimation
}

extension ShimmerAnimatable where Self: UIView {
    func startAnimating() {
        if isAnimating {
            return
        }

        layoutIfNeeded()

        let gradientLayer = composeAnimationLayer()
        layer.mask = gradientLayer

        let animation = composeAnimation()
        gradientLayer.add(animation, forKey: configuration.animationKey)
    }

    func stopAnimating() {
        if !isAnimating {
            return
        }

        layer.mask = nil
    }

    var isAnimating: Bool {
        return layer.animation(forKey: configuration.animationKey) != nil
    }

    func composeAnimationLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.startPoint = configuration.startPoint
        gradientLayer.endPoint = configuration.endPoint
        gradientLayer.locations = configuration.locations
        gradientLayer.colors = configuration.colors
        return gradientLayer
    }

    func composeAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(
            keyPath: configuration.keyPath
        )
        animation.fromValue = configuration.fromValue
        animation.toValue = configuration.toValue
        animation.repeatCount = configuration.repeatCount
        animation.duration = configuration.duration
        return animation
    }
}
