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
//   FloatingActionItemButton.swift

import Foundation
import UIKit
import MacaroonUIKit

// <todo> Remove `FloatingActionItemButton`.
final class FloatingActionItemButton: Control {
    private lazy var theme = FloatingActionItemButtonTheme()

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    var title: String? {
        didSet {
            guard hasTitleLabel else { return }
            titleLabel.text = title
        }
    }

    private lazy var imageViewContainer = FloatingButtomItemImageViewContainer()
    private lazy var imageView = UIImageView()
    private lazy var titleLabel = Label()

    private let hasTitleLabel: Bool

    init(hasTitleLabel: Bool = true) {
        self.hasTitleLabel = hasTitleLabel
        super.init(frame: .zero)

        addImageView(theme)

        if hasTitleLabel {
            addTitleLabel(theme)
        }
    }

    func customize(_ theme: FloatingActionItemButtonTheme) {
        addImageView(theme)
        addTitleLabel(theme)
    }

    func customizeAppearance(_ styleSheet: FloatingActionItemButtonTheme) {}

    func prepareLayout(_ layoutSheet: FloatingActionItemButtonTheme) {}
}

extension FloatingActionItemButton {
    private func addImageView(_ theme: FloatingActionItemButtonTheme) {
        imageViewContainer.customize(theme)

        addSubview(imageViewContainer)
        imageViewContainer.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().priority(.low)
        }


        imageViewContainer.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addTitleLabel(_ theme: FloatingActionItemButtonTheme) {
        titleLabel.customizeAppearance(theme.title)
        titleLabel.draw(shadow: theme.titleShadow)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.trailing.equalTo(imageView.snp.leading).offset(-theme.titleLabelTrailingPadding)
            $0.centerY.equalTo(imageView)
            $0.leading.equalToSuperview()
        }
    }
}

final fileprivate class FloatingButtomItemImageViewContainer:
    View,
    DoubleShadowDrawable {
    var secondShadow: MacaroonUIKit.Shadow?
    var secondShadowLayer = CAShapeLayer()

    func customize(_ theme: FloatingActionItemButtonTheme) {
        isUserInteractionEnabled = false

        draw(shadow: theme.containerFirstShadow)
        draw(secondShadow: theme.containerSecondShadow)
    }

    func customizeAppearance(_ styleSheet: FloatingActionItemButtonTheme) {}

    func prepareLayout(_ layoutSheet: FloatingActionItemButtonTheme) {}
}
