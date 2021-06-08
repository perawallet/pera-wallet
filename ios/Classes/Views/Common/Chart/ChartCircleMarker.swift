// Copyright 2019 Algorand, Inc.

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
//   ChartCircleMarker.swift

import Charts

class ChartCircleMarker: MarkerImage {

    @objc private var outsideColor: UIColor
    @objc private var insideColor: UIColor
    @objc private var radius: CGFloat = 7

    @objc
    public init(outsideColor: UIColor, insideColor: UIColor) {
        self.outsideColor = outsideColor
        self.insideColor = insideColor
        super.init()
    }

    override func draw(context: CGContext, point: CGPoint) {
        let smallRadius = radius - 3
        let bigCircleRect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        let smallCircleRect = CGRect(x: point.x - smallRadius, y: point.y - smallRadius, width: smallRadius * 2, height: smallRadius * 2)

        UIGraphicsPushContext(context)

        context.setFillColor(outsideColor.cgColor)
        context.fillEllipse(in: bigCircleRect)
        context.setFillColor(insideColor.cgColor)
        context.fillEllipse(in: smallCircleRect)

        UIGraphicsPopContext()
    }
}
