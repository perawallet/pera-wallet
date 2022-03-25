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
//   AssetPreviewViewModel.swift

import MacaroonUIKit
import UIKit

struct AssetPreviewModel: Hashable {
    let image: UIImage?
    let secondaryImage: UIImage?
    let assetPrimaryTitle: String?
    let assetSecondaryTitle: String?
    let assetPrimaryValue: String?
    let assetSecondaryValue: String?
}

struct AssetPreviewViewModel:
    PairedViewModel,
    Hashable {
    private(set) var assetImageViewModel: AssetImageViewModel?
    private(set) var secondaryImage: UIImage?
    private(set) var assetPrimaryTitle: EditText?
    private(set) var assetSecondaryTitle: EditText?
    private(set) var assetPrimaryValue: EditText?
    private(set) var assetSecondaryAssetValue: EditText?
    
    init(_ model: AssetPreviewModel) {
        bindSecondaryImage(model.secondaryImage)
        bindAssetPrimaryTitle(model.assetPrimaryTitle)
        bindAssetSecondaryTitle(model.assetSecondaryTitle)
        bindAssetPrimaryValue(model.assetPrimaryValue)
        bindAssetSecondaryValue(model.assetSecondaryValue)
        bindAssetImageView(model.image)
    }
}

extension AssetPreviewViewModel {
    private mutating func bindAssetImageView(_ image: UIImage?) {
        let assetAbbreviationForImage = TextFormatter.assetShortName.format(assetPrimaryTitle?.string)
        
        assetImageViewModel = AssetImageViewModel(
            image: image,
            assetAbbreviationForImage: assetAbbreviationForImage
        )
    }
    
    private mutating func bindSecondaryImage(_ image: UIImage?) {
        self.secondaryImage = image
    }
    
    private mutating func bindAssetPrimaryTitle(_ title: String?) {
        self.assetPrimaryTitle =  .string(title.isNilOrEmpty ? "title-unknown".localized : title)
    }
    
    private mutating func bindAssetSecondaryTitle(_ title: String?) {
        self.assetSecondaryTitle = .string(title)
    }
    
    private mutating func bindAssetPrimaryValue(_ value: String?) {
        self.assetPrimaryValue = .string(value)
    }
    
    private mutating func bindAssetSecondaryValue(_ value: String?) {
        self.assetSecondaryAssetValue = .string(value.isNilOrEmpty ? "asset-no-value".localized : value)
    }
}
