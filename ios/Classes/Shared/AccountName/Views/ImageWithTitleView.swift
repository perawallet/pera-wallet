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
//  ImageWithTitleView.swift

import UIKit
import MacaroonUIKit

final class ImageWithTitleView: View {
    private lazy var imageView = UIImageView()
    private lazy var imageBottomRightBadgeView = UIImageView()
    private lazy var titleLabel = UILabel()

    func customize(_ theme: ImageWithTitleViewTheme) {
        addImageView(theme)
        addTitleLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension ImageWithTitleView {
    private func addImageView(_ theme: ImageWithTitleViewTheme) {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.bottom.top.equalToSuperview()
            $0.fitToSize(theme.imageSize)
        }

        addImageBottomRightBadgeView(theme)
    }

    private func addImageBottomRightBadgeView(_ theme: ImageWithTitleViewTheme) {
        addSubview(imageBottomRightBadgeView)
        imageBottomRightBadgeView.snp.makeConstraints {
            $0.top == imageView.snp.top + theme.imageBottomRightBadgePaddings.top
            $0.leading == theme.imageBottomRightBadgePaddings.leading
        }
    }

    private func addTitleLabel(_ theme: ImageWithTitleViewTheme) {
        titleLabel.customizeAppearance(theme.titleLabel)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.horizontalPadding)
            $0.leading.equalToSuperview().priority(.medium)
            $0.centerY.trailing.equalToSuperview()
        }
    }
}

extension ImageWithTitleView {
    func bindData(_ viewModel: AccountNameViewModel?) {
        imageView.load(from: viewModel?.image)
        imageBottomRightBadgeView.image = viewModel?.imageBottomRightBadge?.uiImage
        titleLabel.text = viewModel?.name
    }
}
