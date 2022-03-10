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
//  InstructionItemView.swift

import UIKit
import MacaroonUIKit

final class InstructionItemView: View {
    private lazy var informationImageView = UIImageView()
    private lazy var titleLabel = UILabel()

    func customize(_ theme: InstructionItemViewTheme) {
        addInformationImageView(theme)
        addTitleLabel(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension InstructionItemView {
    private func addInformationImageView(_ theme: InstructionItemViewTheme) {
        informationImageView.customizeAppearance(theme.image)

        addSubview(informationImageView)
        informationImageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.fitToSize(theme.infoImageSize)
        }
    }
    
    private func addTitleLabel(_ theme: InstructionItemViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(informationImageView.snp.trailing).offset(theme.horizontalPadding)
            $0.top.bottom.trailing.equalToSuperview()
            $0.greaterThanHeight(theme.infoImageSize.h)
        }
    }
}

extension InstructionItemView {
    func bindTitle(_ title: EditText?) {
        titleLabel.editText = title
    }
}
