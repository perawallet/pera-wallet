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
//  PassPhraseVerifyView.swift

import UIKit
import MacaroonUIKit

final class PassphraseVerifyView:
    View,
    ViewModelBindable,
    UIInteractable {
    weak var delegate: PassphraseVerifyViewDelegate?
    
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .next: TargetActionInteraction()
    ]

    private lazy var titleLabel = Label()
    private lazy var firstCardView = PassphraseVerifyCardView()
    private lazy var secondCardView = PassphraseVerifyCardView()
    private lazy var thirdCardView = PassphraseVerifyCardView()
    private lazy var fourthCardView = PassphraseVerifyCardView()

    private lazy var nextButton = Button()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setListeners()
        linkInteractors()
    }

    func customize(_ theme: PassphraseVerifyViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitleLabel(theme)
        addFirstCardView(theme)
        addSecondCardView(theme)
        addThirdCardView(theme)
        addFourthCardView(theme)
        addNextButton(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func linkInteractors() {
        startPublishing(event: .next, for: nextButton)
    }
    
    func setListeners() {
        firstCardView.delegate = self
        secondCardView.delegate = self
        thirdCardView.delegate = self
        fourthCardView.delegate = self
    }
    
    func bindData(_ viewModel: PassphraseVerifyViewModel?) {
        firstCardView.bindData(viewModel?.firstCardViewModel)
        secondCardView.bindData(viewModel?.secondCardViewModel)
        thirdCardView.bindData(viewModel?.thirdCardViewModel)
        fourthCardView.bindData(viewModel?.fourthCardViewModel)
    }
}

extension PassphraseVerifyView {
    private func addTitleLabel(_ theme: PassphraseVerifyViewTheme) {
        titleLabel.customizeAppearance(theme.title)
        titleLabel.editText = theme.titleText

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.titleTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
    
    private func addFirstCardView(_ theme: PassphraseVerifyViewTheme) {
        firstCardView.tag = 0
        firstCardView.customize(theme.cardViewTheme)
        
        addSubview(firstCardView)
        firstCardView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.listTopOffset)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func addSecondCardView(_ theme: PassphraseVerifyViewTheme) {
        secondCardView.tag = 1
        secondCardView.customize(theme.cardViewTheme)
        
        addSubview(secondCardView)
        secondCardView.snp.makeConstraints {
            $0.top.equalTo(firstCardView.snp.bottom).offset(theme.cardViewBottomOffset)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func addThirdCardView(_ theme: PassphraseVerifyViewTheme) {
        thirdCardView.tag = 2
        thirdCardView.customize(theme.cardViewTheme)
        
        addSubview(thirdCardView)
        thirdCardView.snp.makeConstraints {
            $0.top.equalTo(secondCardView.snp.bottom).offset(theme.cardViewBottomOffset)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func addFourthCardView(_ theme: PassphraseVerifyViewTheme) {
        fourthCardView.tag = 3
        fourthCardView.customize(theme.cardViewTheme)
        
        addSubview(fourthCardView)
        fourthCardView.snp.makeConstraints {
            $0.top.equalTo(thirdCardView.snp.bottom).offset(theme.cardViewBottomOffset)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func addNextButton(_ theme: PassphraseVerifyViewTheme) {
        nextButton.customize(theme.nextButtonTheme)
        nextButton.bindData(ButtonCommonViewModel(title: "title-next".localized))
        nextButton.isEnabled = false

        addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.top.equalTo(fourthCardView.snp.bottom).offset(theme.buttonTopOffset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.buttonBottomOffset)
        }
    }
}

extension PassphraseVerifyView {
    func reset() {
        firstCardView.reset()
        secondCardView.reset()
        thirdCardView.reset()
        fourthCardView.reset()
        nextButton.isEnabled = false
    }
    
    func setButtonInteraction() {
        nextButton.isEnabled = true
    }
}

extension PassphraseVerifyView: PassphraseVerifyCardViewDelegate {
    func passphraseVerifyCardViewDidSelectWord(
        _ passphraseVerifyCardView: PassphraseVerifyCardView,
        item: Int
    ) {
        delegate?.passphraseVerifyViewDidSelectMnemonic(
            self,
            section: passphraseVerifyCardView.tag,
            item: item
        )
    }
}

protocol PassphraseVerifyViewDelegate: AnyObject {
    func passphraseVerifyViewDidSelectMnemonic(
        _ passphraseVerifyView: PassphraseVerifyView,
        section: Int,
        item: Int
    )
}

extension PassphraseVerifyView {
    enum Event {
        case next
    }
}
