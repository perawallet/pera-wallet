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

//   GradientView.swift

import Foundation
import MacaroonUIKit
import UIKit

/// <todo>
/// It should be moved into Macaroon, and adapt to the protocol to drawing the gradient.
final class GradientView: MacaroonUIKit.BaseView {
    var colors: [Color]? {
        didSet { setNeedsDraw() }
    }
    var locations: [NSNumber]? {
        didSet { setNeedsDraw() }
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    private var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }

    override func preferredUserInterfaceStyleDidChange() {
        super.preferredUserInterfaceStyleDidChange()
        setNeedsDraw()
    }
}

extension GradientView {
    private func setNeedsDraw() {
        gradientLayer.colors = colors?.map(\.uiColor.cgColor)
        gradientLayer.locations = locations
    }
}
