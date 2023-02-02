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

//   CollectiblePropertyView.swift

import UIKit
import MacaroonUIKit

final class CollectiblePropertyView:
    View,
    ListReusable,
    ViewModelBindable {
    private lazy var backgroundView = UIImageView()
    private lazy var contentView = UIView()
    private lazy var nameLabel = Label()
    private lazy var valueLabel = Label()

    func customize(
        _ theme: CollectiblePropertyViewTheme
    ) {
        addBackground(theme)
        addContent(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension CollectiblePropertyView {
    private func addBackground(_ theme: CollectiblePropertyViewTheme) {
        backgroundView.customizeAppearance(theme.background)

        addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges == 0
        }
    }

    private func addContent(_ theme: CollectiblePropertyViewTheme) {
        backgroundView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(theme.verticallInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }

        addName(theme)
        addValue(theme)
    }

    private func addName(_ theme: CollectiblePropertyViewTheme) {
        nameLabel.customizeAppearance(theme.name)

        contentView.addSubview(nameLabel)
        nameLabel.fitToVerticalIntrinsicSize()
        nameLabel.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addValue(_ theme: CollectiblePropertyViewTheme) {
        valueLabel.customizeAppearance(theme.value)

        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints {
            $0.top == nameLabel.snp.bottom + theme.labelPadding
            $0.leading == 0
            $0.trailing == 0
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
}

extension CollectiblePropertyView {
    func bindData(_ viewModel: CollectiblePropertyViewModel?) {
        nameLabel.editText = viewModel?.name
        valueLabel.editText = viewModel?.value
    }

    class func calculatePreferredSize(
        _ viewModel: CollectiblePropertyViewModel?,
        for theme: CollectiblePropertyViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((0, size.height))
        }

        let width = size.width
        let height = size.height

        let horizontalInset = theme.horizontalInset * 2

        let nameSize = viewModel.name.boundingSize(
            multiline: false,
            fittingSize: CGSize((width - horizontalInset, .greatestFiniteMagnitude))
        )
        let valueSize = viewModel.value.boundingSize(
            multiline: false,
            fittingSize: CGSize((width - horizontalInset, .greatestFiniteMagnitude))
        )

        let contentWidth =
        min(
            size.width,
            max(nameSize.width, valueSize.width) + horizontalInset
        )
        .ceil()
        
        return CGSize((contentWidth, height))
    }
}
