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

//   ShimmerAnimationDisplaying.swift

import UIKit

protocol ShimmerAnimationDisplaying {
    var animatableSubviews: [ShimmerAnimatable] { get }

    func startAnimating()
    func stopAnimating()
    func restartAnimating()
}

extension ShimmerAnimationDisplaying where Self: UIView {
    var animatableSubviews: [ShimmerAnimatable] {
        var shimmableViews = [ShimmerAnimatable]()

        allSubviews.forEach {
            if let subview = $0 as? ShimmerAnimatable {
                shimmableViews.append(subview)
            }
        }

        return shimmableViews
    }
}

extension ShimmerAnimationDisplaying where Self: UIViewController {
    var animatableSubviews: [ShimmerAnimatable] {
        var shimmableViews = [ShimmerAnimatable]()

        view.allSubviews.forEach {
            if let subview = $0 as? ShimmerAnimatable {
                shimmableViews.append(subview)
            }
        }

        return shimmableViews
    }
}

extension ShimmerAnimationDisplaying {
    func startAnimating() {
        animatableSubviews.forEach {
            $0.startAnimating()
        }
    }

    func stopAnimating() {
        animatableSubviews.forEach {
            $0.stopAnimating()
        }
    }

    func restartAnimating() {
        stopAnimating()
        startAnimating()
    }
}

fileprivate extension UIView {
    var allSubviews: [UIView] {
        return subviews.flatMap { [$0] + $0.allSubviews }
    }
}
