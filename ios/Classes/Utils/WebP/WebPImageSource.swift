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

//   WebPImageSource.swift

import Foundation
import Kingfisher
import KingfisherWebP
import MacaroonURLImage
import UIKit

/// <todo> Should we move the WebP library and processor to Macaroon?
public struct WebPImageSource: URLImageSource {
    public let url: URL?
    public let color: UIColor?
    public let placeholder: ImagePlaceholder?
    public let size: CGSize
    public let scale: CGFloat
    public let cornerRadius: CGFloat
    public let forceRefresh: Bool

    public init(
        url: URL?,
        size: CGSize,
        color: UIColor? = nil,
        placeholder: ImagePlaceholder? = nil,
        scale: CGFloat = UIScreen.main.scale,
        cornerRadius: CGFloat = 0,
        forceRefresh: Bool = false
    ) {
        self.url = url
        self.size = size
        self.color = color
        self.placeholder = placeholder
        self.scale = scale
        self.cornerRadius = cornerRadius
        self.forceRefresh = forceRefresh
    }

    public func formImageProcessors() -> [ImageProcessor?] {
        return [
            WebPProcessor(),
            formShapeImageProcessor()
        ]
    }

    private func formShapeImageProcessor() -> ImageProcessor? {
        if cornerRadius > 0 {
            return RoundCornerImageProcessor(
                radius: .point(cornerRadius.scaled(scale)),
                targetSize: size.scaled(scale),
                backgroundColor: .clear
            )
        }

        return nil
    }
}
