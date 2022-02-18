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
//   BadgedImageVIew.swift

import UIKit
import MacaroonUIKit

final class BadgedImageView: Control {
    private(set) lazy var imageView = UIImageView()
    private lazy var badgeImageView = UIImageView()

    func customize(_ theme: BadgedImageViewTheme) {
        addImageView(theme)
        addBadgeImageView(theme)
    }

    func customizeAppearance(_ styleSheet: BadgedImageViewTheme) {}

    func prepareLayout(_ layoutSheet: BadgedImageViewTheme) {}
}

extension BadgedImageView {
    private func addImageView(_ theme: BadgedImageViewTheme) {
        imageView.layer.draw(corner: theme.imageCorner)
        imageView.clipsToBounds = true

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.fitToSize(theme.imageSize)
            $0.edges.equalToSuperview()
        }
    }

    private func addBadgeImageView(_ theme: BadgedImageViewTheme) {
        addSubview(badgeImageView)
        badgeImageView.snp.makeConstraints {
            $0.fitToSize(theme.badgeSize)
            $0.top.equalTo(imageView.snp.top).offset(-theme.badgePaddings.top)
            $0.centerX.equalTo(imageView.snp.trailing).inset(theme.badgePaddings.trailing)
        }
    }
}

extension BadgedImageView {
    func bindData(image: UIImage?, badgeImage: UIImage?) {
        imageView.image = image ?? "icon-user-placeholder".uiImage
        badgeImageView.image = badgeImage
    }

    func bindData(badgeImage: UIImage?) {
        badgeImageView.image = badgeImage
    }

    func bindData(image: UIImage?) {
        imageView.image = image ?? "icon-user-placeholder".uiImage
    }
}
