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
//   AssetImageViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage
import Prism

protocol AssetImageViewModel: AssetImagePlaceholderViewModel {
    var imageSource: PNGImageSource? { get }
    var image: UIImage? { get }
}

extension AssetImageViewModel where Self: Hashable {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(imageSource?.url)
        hasher.combine(image)
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        return lhs.imageSource?.url == rhs.imageSource?.url &&
        lhs.image == rhs.image
    }
}

enum AssetImage {
    case url(URL)
    case algo
    case custom(UIImage)
}

struct AssetImageLargeViewModel:
    AssetImageViewModel,
    Hashable {
    private(set) var imageSource: PNGImageSource?
    private(set) var image: UIImage?
    private(set) var assetAbbreviatedName: EditText?

    init(
        image: AssetImage? = nil,
        assetAbbreviatedName: String? = nil
    ) {
        bindImage(image)
        bindAssetAbbreviatedName(assetAbbreviatedName)
    }

    private mutating func bindImage(_ image: AssetImage?) {
        guard let image = image else {
            return
        }

        switch image {
        case .url(let url):
            let imageSize = CGSize(width: 40, height: 40)
            let prismURL =
            PrismURL(baseURL: url)
                .setExpectedImageSize(imageSize)
                .setImageQuality(.normal)
                .setResizeMode(.fit)
                .build()

            self.imageSource = PNGImageSource(
                url: prismURL,
                size: .resize(imageSize, .aspectFit),
                shape: .rounded(4),
                placeholder: nil
            )
        case .algo:
            self.image = "icon-algo-circle-green".uiImage
        case .custom(let image):
            self.image = image
        }
    }

    private mutating func bindAssetAbbreviatedName(_ name: String?) {
        assetAbbreviatedName = getAssetAbbreviatedName(
            name: name,
            with: TextAttributes(
                font: Fonts.DMSans.regular.make(13),
                lineHeightMultiplier: 1.18
            )
        )
    }
}

struct AssetImageSmallViewModel:
    AssetImageViewModel,
    Hashable {
    private(set) var imageSource: PNGImageSource?
    private(set) var image: UIImage?
    private(set) var assetAbbreviatedName: EditText?

    init(
        image: UIImage? = nil,
        assetAbbreviatedName: String? = nil
    ) {
        bindImage(image)
        bindAssetAbbreviatedName(assetAbbreviatedName)
    }

    private mutating func bindImage(_ image: UIImage?) {
        self.image = image
    }

    private mutating func bindAssetAbbreviatedName(_ name: String?) {
        assetAbbreviatedName = getAssetAbbreviatedName(
            name: name,
            with: TextAttributes(
                font: Fonts.DMSans.medium.make(10),
                lineHeightMultiplier: 0.92
            )
        )
    }
}
