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
//   AssetImageView.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class AssetImageView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var imageView = URLImageView()

    func customize(
        _ theme: AssetImageViewTheme
    ) {
        addImage(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: AssetImageViewModel?
    ) {
        if let image = viewModel?.image {
            imageView.imageContainer.image = image
            return
        }

        imageView.load(from: viewModel?.imageSource)
    }

    func prepareForReuse() {
        imageView.prepareForReuse()
    }
}

extension AssetImageView {
    func addImage(
        _ theme: AssetImageViewTheme
    ) {
        imageView.build(theme.image)

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}
