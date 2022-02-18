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
//  PassPhraseMnemonicView.swift

import UIKit
import MacaroonUIKit

final class PassphraseMnemonicView: View {
    var isSelected = false {
        didSet {
            recustomizeAppearanceWhenSelectedStateDidChange()
        }
    }
    
    private lazy var phraseLabel = Label()

    func customize(_ theme: PassphraseMnemonicViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addPhraseLabel(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension PassphraseMnemonicView {
    private func addPhraseLabel(_ theme: PassphraseMnemonicViewTheme) {
        phraseLabel.adjustsFontSizeToFitWidth = true
        phraseLabel.minimumScaleFactor = 0.7
        phraseLabel.customizeAppearance(theme.title)
        phraseLabel.draw(corner: theme.titleCorner)

        addSubview(phraseLabel)
        phraseLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.center.equalToSuperview()
        }
    }
}

extension PassphraseMnemonicView {
    private func recustomizeAppearanceWhenSelectedStateDidChange() {
        phraseLabel.backgroundColor = isSelected ? AppColors.Shared.Layer.grayLighter.uiColor : .clear
    }
}

extension PassphraseMnemonicView: ViewModelBindable {
    func bindData(_ viewModel: PassphraseMnemonicViewModel?) {
        phraseLabel.text = viewModel?.phrase
    }
}
