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

//   ContactImageProcessor.swift

import Foundation
import UIKit

struct ContactImageProcessor {
    private let data: Data?
    private let size: CGSize?
    private let fallbackImage: FallbackImage

    init(
        data: Data?,
        size: CGSize? = nil,
        fallbackImage: FallbackImage = .default
    ) {
        self.data = data
        self.size = size
        self.fallbackImage = fallbackImage
    }

    func process() -> UIImage? {
        guard let data = data,
              let image = UIImage(data: data) else {

            if let size = size,
               let fallbackImage = fallbackImage.underlyingImage,
               let resizedFallbackImage = fallbackImage.convert(to: size) {
                return resizedFallbackImage
            }

            return fallbackImage.underlyingImage
        }

        if let size = size,
           let resizedImage = image.convert(to: size) {
            return resizedImage
        }

        return image
    }
}

extension ContactImageProcessor {
    struct FallbackImage {
        let underlyingImage: UIImage?

        static let none = FallbackImage(underlyingImage: nil)
        static let `default` = FallbackImage(
            underlyingImage: "icon-user-placeholder".uiImage
        )
    }
}
