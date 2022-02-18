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
//   RekeyTransitionItemView.swift

import UIKit
import MacaroonUIKit

final class RekeyTransitionItemView: View {
    weak var delegate: RekeyConfirmationViewDelegate?

    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var valueLabel = UILabel()

    func customize(_ theme: RekeyTransitionItemViewTheme) {
        addImageView(theme)
        addTitleLabel(theme)
        addValueLabel(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension RekeyTransitionItemView {
    private func addImageView(_ theme: RekeyTransitionItemViewTheme) {
        imageView.customizeAppearance(theme.image)

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
    }

    private func addTitleLabel(_ theme: RekeyTransitionItemViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(theme.titleLabelTopPadding)
            $0.leading.trailing.equalToSuperview()
        }
    }

    private func addValueLabel(_ theme: RekeyTransitionItemViewTheme) {
        valueLabel.customizeAppearance(theme.value)

        addSubview(valueLabel)
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.valueLabelTopPadding)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension RekeyTransitionItemView {
    func bindData(image: UIImage?, title: String?, value: String?) {
        self.imageView.image = image
        self.titleLabel.text = title
        self.valueLabel.text = value
    }
}
