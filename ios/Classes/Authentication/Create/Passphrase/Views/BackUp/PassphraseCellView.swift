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
//  PassphraseCellView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class PassphraseCellView: View {
    private lazy var numberLabel = UILabel()
    private lazy var phraseLabel = UILabel()

    func customize(_ theme: PassphraseCellViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addNumberLabel(theme)
        addPhraseLabel(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension PassphraseCellView {
    private func addNumberLabel(_ theme: PassphraseCellViewTheme) {
        numberLabel.customizeAppearance(theme.numberLabel)

        addSubview(numberLabel)
        numberLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.fitToSize(theme.numberLabelSize)
        }
    }
    
    private func addPhraseLabel(_ theme: PassphraseCellViewTheme) {
        phraseLabel.customizeAppearance(theme.phraseLabel)
        
        addSubview(phraseLabel)
        phraseLabel.snp.makeConstraints {
            $0.centerY.equalTo(numberLabel)
            $0.leading.equalTo(numberLabel.snp.trailing).offset(theme.leadingInset)
            $0.trailing.lessThanOrEqualToSuperview()
        }

        phraseLabel.setContentHuggingPriority(.required, for: .horizontal)
        phraseLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}

extension PassphraseCellView: ViewModelBindable {
    func bindData(_ viewModel: PassphraseCellViewModel?) {
        numberLabel.text = viewModel?.number
        phraseLabel.text = viewModel?.phrase
    }
}
