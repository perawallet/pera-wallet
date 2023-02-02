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

//   ShimmerAnimationConfiguration.swift

import UIKit

@dynamicMemberLookup
struct ShimmerAnimationConfiguration {
    let gradient = Gradient()
    let animation = Animation()

    subscript<T>(dynamicMember keyPath: KeyPath<Gradient, T>) -> T {
        return gradient[keyPath: keyPath]
    }

    subscript<T>(dynamicMember keyPath: KeyPath<Animation, T>) -> T {
        return animation[keyPath: keyPath]
    }

    subscript<T>(dynamicMember keyPath: KeyPath<Gradient.Direction, T>) -> T {
        return gradient.direction[keyPath: keyPath]
    }

    struct Gradient {
        let direction: Direction = .leftToRight
        let colorOne: CGColor = Colors.Other.loadingGradient1.uiColor.cgColor
        let colorTwo: CGColor = Colors.Other.loadingGradient2.uiColor.cgColor
        let locations: [NSNumber] = [0, 0.5, 1]

        var colors: [CGColor] {
            [ colorOne, colorTwo, colorOne ]
        }

        struct Direction {
            let startPoint: CGPoint
            let endPoint: CGPoint

            static let leftToRight = Direction(
                startPoint: CGPoint(x: 0.0, y: 0.5),
                endPoint: CGPoint(x: 1.0, y: 0.5)
            )

            static let rightToLeft = Direction(
                startPoint: CGPoint(x: 1.0, y: 0.5),
                endPoint: CGPoint(x: 0.0, y: 0.5)
            )
        }
    }
    
    struct Animation {
        let animationKey: String = "animation.key.shimmer"
        let keyPath = #keyPath(CAGradientLayer.locations)
        let fromValue = [-1, -0.5, 0]
        let toValue = [1, 1.5, 2]
        let repeatCount: Float = .infinity
        let duration: CFTimeInterval = 1.25
    }
}
