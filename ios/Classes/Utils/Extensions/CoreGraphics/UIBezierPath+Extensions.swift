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

//   UIBezierPath+Extensions.swift

import UIKit

extension UIBezierPath {
    typealias Point = (x: CGFloat, y: CGFloat)

    func move(
        to point: Point
    ) {
        move(to: CGPoint(x: point.x, y: point.y))
    }

    func addCurve(
        _ point: Point,
        from firstPoint: Point,
        to secondPoint: Point
    ) {
        addCurve(
            to: CGPoint(x: point.x, y: point.y),
            controlPoint1: CGPoint(x: firstPoint.x, y: firstPoint.y),
            controlPoint2: CGPoint(x: secondPoint.x, y: secondPoint.y)
        )
    }
}
