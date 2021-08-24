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
//  AccountRecoverView.swift

import UIKit

class AccountRecoverView: BaseView {

    private let layout = Layout<LayoutConstants>()

    weak var delegate: AccountRecoverViewDelegate?

    private(set) var recoverInputViews = [RecoverInputView]()

    private(set) var currentInputView: RecoverInputView?

    private lazy var horizontalStackView: HStackView = {
        let stackView = HStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.spacing = 20.0
        stackView.alignment = .leading
        stackView.clipsToBounds = true
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .horizontal
        stackView.isUserInteractionEnabled = true
        return stackView
    }()

    private lazy var firstColumnStackView: VStackView = {
        let stackView = VStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.spacing = 8.0
        stackView.alignment = .fill
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = true
        return stackView
    }()

    private lazy var secondColumnStackView: VStackView = {
        let stackView = VStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.spacing = 8.0
        stackView.alignment = .fill
        stackView.clipsToBounds = true
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = true
        return stackView
    }()

    override func prepareLayout() {
        setupStackViewLayout()
        addInputViews()
    }
}

extension AccountRecoverView {
    private func setupStackViewLayout() {
        addSubview(horizontalStackView)

        horizontalStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.stackTopInset)
        }

        horizontalStackView.addArrangedSubview(firstColumnStackView)
        horizontalStackView.addArrangedSubview(secondColumnStackView)
    }
}

extension AccountRecoverView {
    func index(of recoverInputView: RecoverInputView) -> Int? {
        return recoverInputViews.firstIndex(of: recoverInputView)
    }
}

extension AccountRecoverView {
    private func addInputViews() {
        fillTheFirstColumnOfInputViews()
        fillTheSecondColumnOfInputViews()
    }

    private func fillTheFirstColumnOfInputViews() {
        for index in 0...Constants.firstColumnCount - 1 {
            let inputView = composeInputView()
            if index == 0 {
                currentInputView = inputView
            }
            firstColumnStackView.addArrangedSubview(inputView)
        }
    }

    private func fillTheSecondColumnOfInputViews() {
        for _ in 0...Constants.secondColumnCount - 1 {
            let inputView = composeInputView()
            secondColumnStackView.addArrangedSubview(inputView)
        }
    }

    private func composeInputView() -> RecoverInputView {
        let inputView = RecoverInputView()
        inputView.delegate = self
        inputView.bind(RecoverInputViewModel(state: .empty, index: recoverInputViews.count))
        recoverInputViews.append(inputView)

        if recoverInputViews.count == Constants.totalMnemonicCount {
            inputView.returnKey = .go
        } else {
            inputView.returnKey = .next
        }

        return inputView
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
    enum Constants {
        static let totalMnemonicCount = 25
        static let firstColumnCount = 13
        static let secondColumnCount = 12
    }
}

extension AccountRecoverView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let stackTopInset: CGFloat = 32.0
        let horizontalInset: CGFloat = 20.0
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
