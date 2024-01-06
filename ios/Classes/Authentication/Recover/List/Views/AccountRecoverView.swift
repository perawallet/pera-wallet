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
//  AccountRecoverView.swift

import UIKit
import MacaroonUIKit

final class AccountRecoverView: View {
    weak var delegate: AccountRecoverViewDelegate?

    private lazy var titleLabel = UILabel()
    private(set) var currentInputView: RecoverInputView?
    private lazy var horizontalStackView = UIStackView()
    private lazy var firstColumnStackView = UIStackView()
    private lazy var secondColumnStackView = UIStackView()

    private(set) var recoverInputViews = [RecoverInputView]()

    lazy var constants = Constants()

    static func mnemonicsForSecureBackup() -> AccountRecoverView {
        let recoverView = AccountRecoverView()
        recoverView.constants = Constants(firstColumnCount: 6, secondColumnCount: 6)
        return recoverView
    }

    func customize(_ theme: AccountRecoverViewTheme) {
        addTitle(theme)
        addHorizontalStackView(theme)
        addInputViews()
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension AccountRecoverView {
    private func addTitle(_ theme: AccountRecoverViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }

    private func addHorizontalStackView(_ theme: AccountRecoverViewTheme) {
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.spacing = theme.horizontalStackViewSpacing
        horizontalStackView.alignment = .leading
        horizontalStackView.clipsToBounds = true
        horizontalStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(horizontalStackView)
        horizontalStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.horizontalStackViewTopInset)
            $0.bottom.lessThanOrEqualToSuperview()
        }

        configureVerticalStackViews(firstColumnStackView, secondColumnStackView, with: theme)
        horizontalStackView.addArrangedSubview(firstColumnStackView)
        horizontalStackView.addArrangedSubview(secondColumnStackView)
    }
}

extension AccountRecoverView {
    private func configureVerticalStackViews(_ stackViews: UIStackView..., with theme: AccountRecoverViewTheme) {
        stackViews.forEach { stackView in
            stackView.distribution = .equalSpacing
            stackView.spacing = theme.verticalStackViewSpacing
            stackView.clipsToBounds = true
            stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            stackView.axis = .vertical
        }
    }
}

extension AccountRecoverView {
    private func addInputViews() {
        fillTheFirstColumnOfInputViews()
        fillTheSecondColumnOfInputViews()
    }

    private func fillTheFirstColumnOfInputViews() {
        for index in 0..<constants.firstColumnCount {
            let inputView = composeInputView()

            if index == 0 {
                currentInputView = inputView
            }

            firstColumnStackView.addArrangedSubview(inputView)
        }
    }

    private func fillTheSecondColumnOfInputViews() {
        for _ in 0..<constants.secondColumnCount {
            let inputView = composeInputView()
            secondColumnStackView.addArrangedSubview(inputView)
        }
    }

    private func composeInputView() -> RecoverInputView {
        let inputView = RecoverInputView()
        inputView.delegate = self
        inputView.bindData(RecoverInputViewModel(state: .empty, index: recoverInputViews.count))
        recoverInputViews.append(inputView)

        if recoverInputViews.count == constants.firstColumnCount + constants.secondColumnCount {
            inputView.returnKey = .go
        } else {
            inputView.returnKey = .next
        }

        return inputView
    }
}

extension AccountRecoverView {
    func index(of recoverInputView: RecoverInputView) -> Int? {
        return recoverInputViews.firstIndex(of: recoverInputView)
    }
}

extension AccountRecoverView: RecoverInputViewDelegate {
    func recoverInputViewDidBeginEditing(_ recoverInputView: RecoverInputView) {
        currentInputView = recoverInputView
        delegate?.accountRecoverView(self, didBeginEditing: recoverInputView)
    }

    func recoverInputViewDidChange(_ recoverInputView: RecoverInputView) {
        delegate?.accountRecoverView(self, didChangeInputIn: recoverInputView)
    }

    func recoverInputViewDidEndEditing(_ recoverInputView: RecoverInputView) {
        delegate?.accountRecoverView(self, didEndEditing: recoverInputView)
    }

    func recoverInputViewShouldReturn(_ recoverInputView: RecoverInputView) -> Bool {
        guard let delegate = delegate else {
            return true
        }

        return delegate.accountRecoverView(self, shouldReturn: recoverInputView)
    }

    func recoverInputView(
        _ recoverInputView: RecoverInputView,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let delegate = delegate else {
            return true
        }

        return delegate.accountRecoverView(self, shouldChange: recoverInputView, charactersIn: range, replacementString: string)
    }
}

extension AccountRecoverView {
    struct Constants {
        let firstColumnCount: Int
        let secondColumnCount: Int

        init() {
            firstColumnCount = 13
            secondColumnCount = 12
        }

        init(firstColumnCount: Int, secondColumnCount: Int) {
            self.firstColumnCount = firstColumnCount
            self.secondColumnCount = secondColumnCount
        }
    }
}

protocol AccountRecoverViewDelegate: AnyObject {
    func accountRecoverView(_ view: AccountRecoverView, didBeginEditing recoverInputView: RecoverInputView)
    func accountRecoverView(_ view: AccountRecoverView, didChangeInputIn recoverInputView: RecoverInputView)
    func accountRecoverView(_ view: AccountRecoverView, didEndEditing recoverInputView: RecoverInputView)
    func accountRecoverView(_ view: AccountRecoverView, shouldReturn recoverInputView: RecoverInputView) -> Bool
    func accountRecoverView(
        _ view: AccountRecoverView,
        shouldChange recoverInputView: RecoverInputView,
        charactersIn range: NSRange,
        replacementString string: String
    ) -> Bool
}
