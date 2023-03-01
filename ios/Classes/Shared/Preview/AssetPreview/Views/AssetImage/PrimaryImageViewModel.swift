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
//   PrimaryImageViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonURLImage
import Prism

protocol PrimaryImageViewModel {
    var imageSource: DefaultURLImageSource? { get }
    var image: UIImage? { get }
}

extension PrimaryImageViewModel where Self: Hashable {
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

extension PrimaryImageViewModel {
    typealias TextAttributes = (font: CustomFont, lineHeightMultiplier: LayoutMetric)
    
    func getPlaceholder(
        _ aPlaceholder: String?,
        with attributes: TextAttributes
    ) -> ImagePlaceholder? {
        guard let aPlaceholder = aPlaceholder else {
            return nil
        }

        let font = attributes.font
        let lineHeightMultiplier = attributes.lineHeightMultiplier

        let placeholderText: EditText = .attributedString(
            aPlaceholder.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .textAlignment(.center),
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )

        return ImagePlaceholder(
            image: AssetImageSource(
                asset: "asset-image-placeholder-border".uiImage
            ),
            text: placeholderText
        )
    }

    func setPrismImage(
        _ url: URL?,
        size: CGSize,
        shape: ImageShape,
        placeholder: String?,
        placeholderAttributes: TextAttributes
    ) -> DefaultURLImageSource {
        let prismURL = PrismURL(baseURL: url)?
            .setExpectedImageSize(size)
            .setImageQuality(.normal)
            .build()

        return DefaultURLImageSource(
            url: prismURL,
            shape: shape,
            placeholder: getPlaceholder(
                placeholder,
                with: placeholderAttributes
            )
        )
    }
}

enum AssetImage {
    case url(URL?, title: String?)
    case algo
    case custom(UIImage)
}

struct StandardAssetImageViewModel:
    PrimaryImageViewModel,
    Hashable {
    private(set) var imageSource: DefaultURLImageSource?
    private(set) var image: UIImage?

    init(
        image: AssetImage
    ) {
        bindImage(
            image: image
        )
    }

    private mutating func bindImage(
        image: AssetImage
    ) {
        switch image {
        case .url(let url, let title):
            let imageSize = CGSize(width: 40, height: 40)
            let placeholder = TextFormatter.assetShortName.format(
                (title.isNilOrEmpty ? "title-unknown".localized : title!)
            )

            self.imageSource = setPrismImage(
                url,
                size: imageSize,
                shape: .circle,
                placeholder: placeholder,
                placeholderAttributes: TextAttributes(
                    font: Fonts.DMSans.regular.make(13),
                    lineHeightMultiplier: 1.18
                )
            )
        case .algo:
            self.image = "icon-algo-circle".uiImage
        case .custom(let image):
            self.image = image
        }
    }
}

struct AssetImageLargeViewModel:
    PrimaryImageViewModel,
    Hashable {
    private(set) var imageSource: DefaultURLImageSource?
    private(set) var image: UIImage?

    init(
        image: AssetImage
    ) {
        bindImage(
            image: image
        )
    }

    private mutating func bindImage(
        image: AssetImage
    ) {
        switch image {
        case .url(let url, let title):
            let imageSize = CGSize(width: 40, height: 40)
            let placeholder = TextFormatter.assetShortName.format(
                (title.isNilOrEmpty ? "title-unknown".localized : title!)
            )

            self.imageSource = setPrismImage(
                url,
                size: imageSize,
                shape: .rounded(4),
                placeholder: placeholder,
                placeholderAttributes: TextAttributes(
                    font: Fonts.DMSans.regular.make(13),
                    lineHeightMultiplier: 1.18
                )
            )
        case .algo:
            self.image = "icon-algo-circle".uiImage
        case .custom(let image):
            self.image = image
        }
    }
}

struct AssetImageSmallViewModel:
    PrimaryImageViewModel,
    Hashable {
    private(set) var imageSource: DefaultURLImageSource?
    private(set) var image: UIImage?

    init(
        image: AssetImage
    ) {
        bindImage(
            image: image
        )
    }

    private mutating func bindImage(
        image: AssetImage
    ) {
        switch image {
        case .url(let url, let title):
            let imageSize = CGSize(width: 24, height: 24)
            let placeholder = TextFormatter.assetShortName.format(
                (title.isNilOrEmpty ? "title-unknown".localized : title!)
            )

            self.imageSource = setPrismImage(
                url,
                size: imageSize,
                shape: .rounded(4),
                placeholder: placeholder,
                placeholderAttributes: TextAttributes(
                    font: Fonts.DMSans.medium.make(10),
                    lineHeightMultiplier: 0.92
                )
            )
        case .algo:
            self.image = "icon-algo-circle".uiImage
        case .custom(let image):
            self.image = image
        }
    }
}

extension PrismURL {
    convenience init?(baseURL: URL?) {
        guard let baseURL = baseURL else {
            return nil
        }

        self.init(baseURL: baseURL)
    }
}
