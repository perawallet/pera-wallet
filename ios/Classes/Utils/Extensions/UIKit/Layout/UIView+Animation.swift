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
//  UIView+Animation.swift

import UIKit

extension UIView {
    func rotate360Degrees(duration: Double, repeatCount: Float, isClockwise: Bool) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: isClockwise ? Double.pi * 2 : -Double.pi * 2 )
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = repeatCount
        layer.add(rotation, forKey: "rotationAnimation")
    }
}
