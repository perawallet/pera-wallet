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

//   CollectibleMediaTapInfoView.swift

import UIKit
import MacaroonUIKit

final class CollectibleMediaTapInfoView: View {

    private lazy var contentView = MacaroonUIKit.BaseView()
    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        customize(CollectibleMediaTapInfoViewTheme())
    }

    func customize(
        _ theme: CollectibleMediaTapInfoViewTheme
    ) {
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension CollectibleMediaTapInfoView {
    private func addContent(
        _ theme: CollectibleMediaTapInfoViewTheme
    ) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading >= 0
            $0.bottom == 0
            $0.trailing <= 0
            $0.centerX == 0
        }

        addImageView(theme)
        addTitleLabel(theme)
    }
    
    private func addImageView(
        _ theme: CollectibleMediaTapInfoViewTheme
    ) {
        imageView.customizeAppearance(theme.image)
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.leading == 0
            $0.centerY == 0
        }
    }

    private func addTitleLabel(
        _ theme: CollectibleMediaTapInfoViewTheme
    ) {
        titleLabel.customizeAppearance(theme.title)

        contentView.addSubview(titleLabel)
        titleLabel.fitToVerticalIntrinsicSize()
        titleLabel.snp.makeConstraints {
            $0.top == 0
            $0.leading == imageView.snp.trailing + theme.iconOffset
            $0.bottom == 0
            $0.trailing == 0
            $0.greaterThanHeight(theme.iconSize.h)
        }
    }
}
