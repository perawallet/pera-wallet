// Copyright 2019 Algorand, Inc.

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

class InputSuggestionView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var suggestionLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.systemFont(ofSize: 16.0, weight: .regular))
            .withTextColor(Colors.Component.inputSuggestionText)
            .withAlignment(.center)
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.InputSuggestionView.separator
        return view
    }()

    override func configureAppearance() {
        backgroundColor = Colors.Component.inputSuggestionBackground
    }

    override func prepareLayout() {
        setupSuggestionLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension InputSuggestionView {
    private func setupSuggestionLabelLayout() {
        addSubview(suggestionLabel)

        suggestionLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.top.bottom.lessThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.suggestionTrailingInset)
        }
    }

    private func setupSeparatorViewLayout() {
        addSubview(separatorView)

        separatorView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(layout.current.separatorVerticalInset)
            make.width.equalTo(layout.current.separatorWidth)
        }
    }
}

extension InputSuggestionView {
    func bind(_ viewModel: InputSuggestionViewModel) {
        suggestionLabel.text = viewModel.suggestion
        separatorView.isHidden = viewModel.isSeparatorHidden
    }
}

extension InputSuggestionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let suggestionTrailingInset: CGFloat = 2.0
        let separatorVerticalInset: CGFloat = 10.0
        let separatorWidth: CGFloat = 1.0
    }
}

extension Colors {
    fileprivate enum InputSuggestionView {
        static let separator = color("inputSuggestionSeparatorColor")
    }
}
