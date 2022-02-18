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
//   InputSuggestionView.swift

import UIKit
import MacaroonUIKit

final class InputSuggestionView: View {
    private lazy var suggestionLabel = UILabel()
    private lazy var separatorView = UIView()

    func customize(_ theme: InputSuggestionViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addSuggestionLabel(theme)
        addSeparatorView(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension InputSuggestionView {
    private func addSuggestionLabel(_ theme: InputSuggestionViewTheme) {
        suggestionLabel.customizeAppearance(theme.suggestionTitle)

        addSubview(suggestionLabel)
        suggestionLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.top.bottom.lessThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().inset(theme.suggestionTrailingInset)
        }
    }

    private func addSeparatorView(_ theme: InputSuggestionViewTheme) {
        separatorView.backgroundColor = theme.separator.color

        addSubview(separatorView)
        separatorView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(theme.separatorVerticalInset)
            $0.fitToWidth(theme.separator.size)
        }
    }
}

extension InputSuggestionView: ViewModelBindable {
    func bindData(_ viewModel: InputSuggestionViewModel?) {
        suggestionLabel.text = viewModel?.suggestion
        separatorView.isHidden = (viewModel?.isSeparatorHidden).falseIfNil
    }
}
