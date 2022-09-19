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

//   String+ImageRendering.swift

import CoreGraphics
import Foundation
import UIKit

extension String {
    func toPlaceholderImage(size: CGSize) -> UIImage {
        let text = self
        return UIGraphicsImageRenderer(size: size).image {
            context in

            let cgContext = context.cgContext

            let fillRect = CGRect(origin: .zero, size: size)
            cgContext.setFillColor(Colors.Defaults.background.uiColor.cgColor)
            cgContext.fillEllipse(in: fillRect)

            /// <note>
            /// The center of the border is the edge of your path, that's why the frame of the
            /// border is a bit smaller.
            let borderWidth: CGFloat = 1
            let borderRect = CGRect(
                origin: .init(x: borderWidth / 2, y: borderWidth / 2),
                size: .init(width: size.width - borderWidth, height: size.height - borderWidth)
            )
            cgContext.setLineWidth(borderWidth)
            cgContext.setStrokeColor(Colors.Layer.grayLighter.uiColor.cgColor)
            cgContext.strokeEllipse(in: borderRect)

            var textAttributes: [NSAttributedString.Key: Any] = [:]
            textAttributes[.font] = Typography.footnoteRegular().uiFont
            textAttributes[.foregroundColor] = Colors.Text.gray.uiColor

            let textSize = text.size(withAttributes: textAttributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(
                in: textRect,
                withAttributes: textAttributes
            )
        }
    }
}
