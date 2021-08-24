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
//  NumpadView.swift

import UIKit

class NumpadView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: NumpadViewDelegate?
    
    private lazy var firstRowStackView: UIStackView = {
        createRow()
    }()
    
    private lazy var numberOneButton = NumpadButton(numpadKey: .number("1"))
    
    private lazy var numberTwoButton = NumpadButton(numpadKey: .number("2"))
    
    private lazy var numberThreeButton = NumpadButton(numpadKey: .number("3"))
    
    private lazy var secondRowStackView: UIStackView = {
        createRow()
    }()
    
    private lazy var numberFourButton = NumpadButton(numpadKey: .number("4"))
    
    private lazy var numberFiveButton = NumpadButton(numpadKey: .number("5"))
    
    private lazy var numberSixButton = NumpadButton(numpadKey: .number("6"))
    
    private lazy var thirdRowStackView: UIStackView = {
        createRow()
    }()
    
    private lazy var numberSevenButton = NumpadButton(numpadKey: .number("7"))
    
    private lazy var numberEightButton = NumpadButton(numpadKey: .number("8"))
    
    private lazy var numberNineButton = NumpadButton(numpadKey: .number("9"))
    
    private lazy var fourthRowStackView: UIStackView = {
        createRow()
    }()
    
    private lazy var spacingButton = NumpadButton(numpadKey: .spacing)
    
    private lazy var zeroButton = NumpadButton(numpadKey: .number("0"))
    
    private lazy var deleteButton = NumpadButton(numpadKey: .delete)
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }
    
    override func linkInteractors() {
        [
            numberOneButton, numberTwoButton, numberThreeButton, numberFourButton, numberFiveButton, numberSixButton, numberSevenButton,
            numberEightButton, numberNineButton, zeroButton, deleteButton
        ].forEach { $0.addTarget(self, action: #selector(notifyDelegateToAddNumpadValue), for: .touchUpInside) }
    }
    
    override func prepareLayout() {
        setupFirstRowStackViewLayout()
        setupSecondRowStackViewLayout()
        setupThirdRowStackViewLayout()
        setupFourthRowStackViewLayout()
    }
}

extension NumpadView {
    @objc
    private func notifyDelegateToAddNumpadValue(sender: NumpadButton) {
        delegate?.numpadView(self, didSelect: sender.numpadKey)
    }
}

extension NumpadView {
    private func setupFirstRowStackViewLayout() {
        addSubview(firstRowStackView)
        
        firstRowStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(layout.current.stackViewHeight)
            make.centerX.equalToSuperview()
        }
        
        firstRowStackView.addArrangedSubview(numberOneButton)
        firstRowStackView.addArrangedSubview(numberTwoButton)
        firstRowStackView.addArrangedSubview(numberThreeButton)
    }
    
    private func setupSecondRowStackViewLayout() {
        addSubview(secondRowStackView)
        
        secondRowStackView.snp.makeConstraints { make in
            make.top.equalTo(firstRowStackView.snp.bottom).offset(layout.current.stackViewSpacing)
            make.height.equalTo(layout.current.stackViewHeight)
            make.centerX.equalToSuperview()
        }
        
        secondRowStackView.addArrangedSubview(numberFourButton)
        secondRowStackView.addArrangedSubview(numberFiveButton)
        secondRowStackView.addArrangedSubview(numberSixButton)
    }
    
    private func setupThirdRowStackViewLayout() {
        addSubview(thirdRowStackView)
        
        thirdRowStackView.snp.makeConstraints { make in
            make.top.equalTo(secondRowStackView.snp.bottom).offset(layout.current.stackViewSpacing)
            make.height.equalTo(layout.current.stackViewHeight)
            make.centerX.equalToSuperview()
        }
        
        thirdRowStackView.addArrangedSubview(numberSevenButton)
        thirdRowStackView.addArrangedSubview(numberEightButton)
        thirdRowStackView.addArrangedSubview(numberNineButton)
    }
    
    private func setupFourthRowStackViewLayout() {
        addSubview(fourthRowStackView)
        
        fourthRowStackView.snp.makeConstraints { make in
            make.top.equalTo(thirdRowStackView.snp.bottom).offset(layout.current.stackViewSpacing)
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.stackViewHeight)
            make.centerX.equalToSuperview()
        }
        
        fourthRowStackView.addArrangedSubview(spacingButton)
        fourthRowStackView.addArrangedSubview(zeroButton)
        fourthRowStackView.addArrangedSubview(deleteButton)
    }
}

extension NumpadView {
    private func createRow() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = layout.current.stackViewSpacing
        stackView.isUserInteractionEnabled = true
        return stackView
    }
}

extension NumpadView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let stackViewSpacing: CGFloat = 24.0 * verticalScale
        let stackViewHeight: CGFloat = 72.0 * verticalScale
    }
}

protocol NumpadViewDelegate: AnyObject {
    func numpadView(_ numpadView: NumpadView, didSelect value: NumpadKey)
}

enum NumpadKey {
    case spacing
    case number(String)
    case delete
}
