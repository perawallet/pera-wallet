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
//  NumpadView.swift

import UIKit
import MacaroonUIKit
import MacaroonUtils
import Foundation

final class NumpadView: View {
    weak var delegate: NumpadViewDelegate?
    
    private lazy var firstRowStackView = UIStackView()
    private lazy var numberOneButton = NumpadButton(numpadKey: .number("1"))
    private lazy var numberTwoButton = NumpadButton(numpadKey: .number("2"))
    private lazy var numberThreeButton = NumpadButton(numpadKey: .number("3"))
    
    private lazy var secondRowStackView = UIStackView()
    private lazy var numberFourButton = NumpadButton(numpadKey: .number("4"))
    private lazy var numberFiveButton = NumpadButton(numpadKey: .number("5"))
    private lazy var numberSixButton = NumpadButton(numpadKey: .number("6"))
    
    private lazy var thirdRowStackView = UIStackView()
    private lazy var numberSevenButton = NumpadButton(numpadKey: .number("7"))
    private lazy var numberEightButton = NumpadButton(numpadKey: .number("8"))
    private lazy var numberNineButton = NumpadButton(numpadKey: .number("9"))
    
    private lazy var fourthRowStackView = UIStackView()
    private lazy var leftButton = NumpadButton(numpadKey: .spacing)
    private lazy var zeroButton = NumpadButton(numpadKey: .number("0"))
    private lazy var deleteButton = NumpadButton(numpadKey: .delete)

    var leftButtonIsHidden: Bool = false {
        didSet {
            leftButton.alpha = leftButtonIsHidden ? 0 : 1
        }
    }

    var deleteButtonIsHidden: Bool = true {
        didSet {
            guard deleteButtonIsHidden != oldValue else { return }

            toggleDeleteButtonVisibility(for: deleteButtonIsHidden)
        }
    }

    private var deleteButtonRepeater: Repeater?
    private let deleteButtonRepeaterInterval: TimeInterval = 0.01
    private var deleteButtonRepeaterFireCount = 0

    private var deleteButtonRepeaterFireCountModulo: Int {
        if deleteButtonRepeaterFireCount > 200 {
            return 1
        } else if deleteButtonRepeaterFireCount > 100 {
            return 2
        } else {
            return 10
        }
    }

    private let mode: Mode

    init(mode: Mode = .passcode) {
        self.mode = mode
        super.init(frame: .zero)
        customizeButtonsForMode()
    }

    deinit {
        resetDeleteButtonRepeater()
    }

    func customize(_ theme: NumpadViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addFirstRowStackView(theme)
        addSecondRowStackView(theme)
        addThirdRowStackView(theme)
        addFourthRowStackView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func linkInteractors() {
        [
            numberOneButton, numberTwoButton, numberThreeButton,
            numberFourButton, numberFiveButton, numberSixButton,
            numberSevenButton, numberEightButton, numberNineButton,
            zeroButton, deleteButton
        ].forEach {
            $0.addTarget(self, action: #selector(didSelect), for: .touchUpInside)
        }

        let longPressDelete = UILongPressGestureRecognizer(
            target: self,
            action: #selector(continuouslyDelete)
        )
        longPressDelete.minimumPressDuration = 0.25
        deleteButton.addGestureRecognizer(longPressDelete)

        switch mode {
        case .decimal:
            leftButton.addTarget(self, action: #selector(didSelect), for: .touchUpInside)
        default:
            return
        }
    }

    private func customizeButtonsForMode() {
        switch mode {
        case .decimal:
            self.leftButton = NumpadButton(numpadKey: .decimalSeparator)
        case .passcode:
            self.leftButton = NumpadButton(numpadKey: .spacing)
            self.leftButton.alpha = 0
        }
    }
}

/// <note>
/// Repeater for continuously deleting.
extension NumpadView {
    @objc
    private func continuouslyDelete(
        recognizer: UILongPressGestureRecognizer
    ) {
        handleGesture(recognizer)
    }

    private func handleGesture(
        _ recognizer: UILongPressGestureRecognizer
    ) {
        if recognizer.state == .began {
            recognizer.cancelsTouchesInView = false

            toggleAllButtonsInteraction(isEnabled: false)
            scheduleDeleteButtonRepeater()
            return
        }

        if recognizer.state == .ended {
            recognizer.cancelsTouchesInView = true

            toggleAllButtonsInteraction(isEnabled: true)
            resetDeleteButtonRepeater()
        }
    }

    private func handleDeleteButtonRepeaterFire() {
        deleteButtonRepeaterFireCount += 1

        if deleteButtonRepeaterFireCount % deleteButtonRepeaterFireCountModulo == 0 {
            didSelect(sender: deleteButton)
        }
    }

    private func scheduleDeleteButtonRepeater() {
        deleteButtonRepeater = Repeater(intervalInSeconds: deleteButtonRepeaterInterval) { [weak self] in
            asyncMain { [weak self] in
                self?.handleDeleteButtonRepeaterFire()
            }
        }

        deleteButtonRepeater?.resume(immediately: false)
    }

    private func resetDeleteButtonRepeater() {
        deleteButtonRepeater?.invalidate()
        deleteButtonRepeater = nil
        deleteButtonRepeaterFireCount = 0
    }

    private func toggleAllButtonsInteraction(isEnabled: Bool) {
        [
            numberOneButton, numberTwoButton, numberThreeButton,
            numberFourButton, numberFiveButton, numberSixButton,
            numberSevenButton, numberEightButton, numberNineButton,
            zeroButton
        ].forEach {
            $0.isEnabled = isEnabled
        }
    }
}

extension NumpadView {
    @objc
    private func didSelect(sender: NumpadButton) {
        delegate?.numpadView(self, didSelect: sender.numpadKey)
    }
}

extension NumpadView {
    private func addFirstRowStackView(_ theme: NumpadViewTheme) {
        configureStackView(firstRowStackView, with: theme)

        addSubview(firstRowStackView)
        firstRowStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(theme.stackViewHeight)
            $0.centerX.equalToSuperview()
        }
        
        firstRowStackView.addArrangedSubview(numberOneButton)
        firstRowStackView.addArrangedSubview(numberTwoButton)
        firstRowStackView.addArrangedSubview(numberThreeButton)
    }
    
    private func addSecondRowStackView(_ theme: NumpadViewTheme) {
        configureStackView(secondRowStackView, with: theme)

        addSubview(secondRowStackView)
        secondRowStackView.snp.makeConstraints {
            $0.top.equalTo(firstRowStackView.snp.bottom).offset(theme.stackViewTopPadding)
            $0.height.equalTo(theme.stackViewHeight)
            $0.centerX.equalToSuperview()
        }
        
        secondRowStackView.addArrangedSubview(numberFourButton)
        secondRowStackView.addArrangedSubview(numberFiveButton)
        secondRowStackView.addArrangedSubview(numberSixButton)
    }
    
    private func addThirdRowStackView(_ theme: NumpadViewTheme) {
        configureStackView(thirdRowStackView, with: theme)

        addSubview(thirdRowStackView)
        thirdRowStackView.snp.makeConstraints {
            $0.top.equalTo(secondRowStackView.snp.bottom).offset(theme.stackViewTopPadding)
            $0.height.equalTo(theme.stackViewHeight)
            $0.centerX.equalToSuperview()
        }
        
        thirdRowStackView.addArrangedSubview(numberSevenButton)
        thirdRowStackView.addArrangedSubview(numberEightButton)
        thirdRowStackView.addArrangedSubview(numberNineButton)
    }
    
    private func addFourthRowStackView(_ theme: NumpadViewTheme) {
        configureStackView(fourthRowStackView, with: theme)

        addSubview(fourthRowStackView)
        fourthRowStackView.snp.makeConstraints {
            $0.top.equalTo(thirdRowStackView.snp.bottom).offset(theme.stackViewTopPadding)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(theme.stackViewHeight)
            $0.centerX.equalToSuperview()
        }
        
        fourthRowStackView.addArrangedSubview(leftButton)
        fourthRowStackView.addArrangedSubview(zeroButton)
        fourthRowStackView.addArrangedSubview(deleteButton)

        deleteButton.alpha = 0
    }
}

extension NumpadView {
    private func toggleDeleteButtonVisibility(
        for isHidden: Bool
    ) {
        UIView.animate(withDuration: 0.3) {
            self.deleteButton.alpha = isHidden ? 0 : 1
        }
    }
}

extension NumpadView {
    private func configureStackView(_ stackView: UIStackView, with theme: NumpadViewTheme) {
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = theme.stackViewSpacing
    }
}

protocol NumpadViewDelegate: AnyObject {
    func numpadView(_ numpadView: NumpadView, didSelect value: NumpadButton.NumpadKey)
}

extension NumpadView {
    enum Mode {
        case decimal
        case passcode
    }
}
