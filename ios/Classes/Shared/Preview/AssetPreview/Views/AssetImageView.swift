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

import MacaroonUIKit
import UIKit

final class AssetImageView: View {
    lazy var theme: AssetImageViewTheme = AssetImageViewLargerTheme()
    private lazy var assetImageView = UIImageView()
    private lazy var assetNameLabel = UILabel()

    private var assetName: String? {
        didSet {
            guard assetName != nil else {
                return
            }

            addLabel(theme)
            draw(corner: theme.corner)
            draw(border: theme.border)
        }
    }
    
    private var image: UIImage? {
        didSet {
            guard image != nil else {
                return
            }

            addImage(theme)
        }
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension AssetImageView {
    func addImage(_ theme: AssetImageViewTheme) {
        assetImageView.image = image

        addSubview(assetImageView)
        assetImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func addLabel(_ theme: AssetImageViewTheme) {
        assetNameLabel.customizeAppearance(theme.nameText)
        assetNameLabel.text = assetName

        addSubview(assetNameLabel)
        assetNameLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AssetImageView {
    func prepareForReuse() {
        assetNameLabel.text = nil
        assetImageView.image = nil
    }
}

extension AssetImageView: ViewModelBindable {
    func bindData(_ viewModel: AssetImageViewModel?) {
        if let image = viewModel?.image {
            self.image = image
            return
        }

        if let assetName = viewModel?.assetAbbreviationForImage {
            self.assetName = assetName
        }
    }
}
