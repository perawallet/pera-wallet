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

//   RightAccessorizedLabel.swift

import Foundation
import MacaroonUIKit
import UIKit

final class RightAccessorizedLabel:
    UIView,
    ViewModelBindable {
    private lazy var textView = UILabel()
    private lazy var accessoryView = ImageView()

    func customize(_ style: RightAccessorizedLabelStyle) {
        addText(style)
        addAccessory(style)

        updateTextAfterAddingAccessory(style)
    }

    func bindData(_ viewModel: RightAccessorizedLabelModel?) {
        if let text = viewModel?.text {
            text.load(in: textView)
        } else {
            textView.text = nil
            textView.attributedText = nil
        }

        if let accessory = viewModel?.accessory {
            accessory.load(in: accessoryView)
        } else {
            accessoryView.image = nil
        }
    }

    static func calculatePreferredSize(
        _ viewModel: RightAccessorizedLabelModel?,
        for layoutSheet: RightAccessorizedLabelStyle,
        fittingIn size: CGSize
    ) -> CGSize {
        return .zero
    }
}

extension RightAccessorizedLabel {
    private func addText(_ style: RightAccessorizedLabelStyle) {
        textView.customizeAppearance(style.text)

        addSubview(textView)
        textView.fitToHorizontalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        textView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        textView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func updateTextAfterAddingAccessory(_ style: RightAccessorizedLabelStyle) {
        textView.snp.makeConstraints {
            $0.height >= accessoryView
        }
    }

    private func addAccessory(_ style: RightAccessorizedLabelStyle) {
        accessoryView.customizeAppearance(style.accessory)

        addSubview(accessoryView)
        accessoryView.contentEdgeInsets = style.accessoryContentOffset
        accessoryView.fitToIntrinsicSize()
        accessoryView.snp.makeConstraints {
            $0.centerY == textView
            $0.leading == textView.snp.trailing
            $0.trailing == 0
        }
    }
}
