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
//   TutorialStepsView.swift

import MacaroonUIKit
import UIKit

final class TutorialStepsView: View {
    weak var delegate: TutorialStepsViewDelegate?

    private lazy var verticalStackView = UIStackView()

    var troubleshoots: [Troubleshoot] = [] {
        didSet {
            customize(TutorialStepsViewTheme())
        }
    }
    
    func customize(_ theme: TutorialStepsViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        addVerticalStackView(theme)

        for (index, step) in troubleshoots.enumerated() {
            let horizontalStackView = UIStackView()
            horizontalStackView.spacing = theme.horizontalSpacing
            horizontalStackView.distribution = .fillProportionally
            horizontalStackView.alignment = .top

            let numberView = TutorialNumberView()
            numberView.customize(TutorialNumberViewTheme())
            numberView.bindData(TutorialNumberViewModel(index + 1))

            let textView = UITextView()
            textView.backgroundColor = theme.backgroundColor.uiColor
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.dataDetectorTypes = .link
            textView.textContainerInset = .zero
            textView.linkTextAttributes = theme.textViewLinkAttributes.asSystemAttributes()
            textView.delegate = self
            textView.attributedText = bindHTML(step.explanation)

            horizontalStackView.addArrangedSubview(numberView)
            horizontalStackView.addArrangedSubview(textView)

            verticalStackView.addArrangedSubview(horizontalStackView)
        }
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension TutorialStepsView {
    func addVerticalStackView(_ theme: TutorialStepsViewTheme) {
        addSubview(verticalStackView)
        verticalStackView.axis = .vertical
        verticalStackView.spacing = theme.verticalSpacing

        verticalStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
}

extension TutorialStepsView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        delegate?.tutorialStepsView(self, didTapURL: URL)
        return false
    }
}

extension TutorialStepsView {
    func bindHTML(_ HTML: String?) -> NSAttributedString? {
        guard let data = HTML?.data(using: .unicode),
            let attributedString = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) else {
            return nil
        }

        attributedString.addAttributes(
            [
                NSAttributedString.Key.font: Fonts.DMSans.regular.make(15).uiFont,
                NSAttributedString.Key.foregroundColor: Colors.Text.main.uiColor
            ],
            range: NSRange(location: 0, length: attributedString.string.count)
        )
        return attributedString
    }
}

extension TutorialStepsView: ViewModelBindable {
    func bindData(_ viewModel: TutorialStepViewModel?) {
        self.troubleshoots = viewModel?.steps ?? []
    }
}

protocol TutorialStepsViewDelegate: AnyObject {
    func tutorialStepsView(_ view: TutorialStepsView, didTapURL URL: URL)
}
