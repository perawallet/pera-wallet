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

//   PassphraseVerifyCardView.swift

import UIKit
import MacaroonUIKit

final class PassphraseVerifyCardView:
    View,
    ViewModelBindable {
    weak var delegate: PassphraseVerifyCardViewDelegate?
    
    private lazy var theme = PassphraseVerifyCardViewTheme()
    
    private lazy var headerLabel = Label()
    private lazy var containerView = TripleShadowView()
    private lazy var stackView = VStackView()
    private lazy var firstMnemonicLabel = Label()
    private lazy var secondMnemonicLabel = Label()
    private lazy var thirdMnemonicLabel = Label()
    
    private var cardIndex: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        linkInteractors()
    }
    
    func customize(_ theme: PassphraseVerifyCardViewTheme) {
        addHeader(theme)
        addContainerView(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func linkInteractors() {
        firstMnemonicLabel.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(updateForSelection(_:))
            )
        )
        secondMnemonicLabel.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(updateForSelection(_:))
            )
        )
        thirdMnemonicLabel.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(updateForSelection(_:))
            )
        )
    }
    
    func bindData(_ viewModel: PassphraseVerifyCardViewModel?) {
        cardIndex = viewModel?.cardIndex
        headerLabel.editText = viewModel?.headerText
        firstMnemonicLabel.editText = viewModel?.firstMnemonic
        secondMnemonicLabel.editText = viewModel?.secondMnemonic
        thirdMnemonicLabel.editText = viewModel?.thirdMnemonic
    }
}

extension PassphraseVerifyCardView {
    @objc
    private func updateForSelection(_ sender: UITapGestureRecognizer) {
        guard let labelTag = sender.view?.tag else {
            return
        }
        
        switch labelTag {
        case 0:
            updateBackground(word: firstMnemonicLabel)
        case 1:
            updateBackground(word: secondMnemonicLabel)
        case 2:
            updateBackground(word: thirdMnemonicLabel)
        default:
            return
        }
        
        delegate?.passphraseVerifyCardViewDidSelectWord(self, item: labelTag)
    }
    
    private func updateBackground(word: Label) {
        stackView.subviews.forEach {
            $0.backgroundColor = theme.deactiveColor
        }
        word.backgroundColor = theme.activeColor
    }
    
    func reset() {
        cardIndex = nil
        stackView.subviews.forEach {
            $0.backgroundColor = theme.deactiveColor
        }
    }
}

extension PassphraseVerifyCardView {
    private func addHeader(_ theme: PassphraseVerifyCardViewTheme) {
        headerLabel.customizeAppearance(theme.headerLabel)
        
        addSubview(headerLabel)
        headerLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    
    private func addContainerView(_ theme: PassphraseVerifyCardViewTheme) {
        containerView.draw(shadow: theme.containerViewFirstShadow)
        containerView.draw(secondShadow: theme.containerViewSecondShadow)
        containerView.draw(thirdShadow: theme.containerViewThirdShadow)
        
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom).offset(theme.containerViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview()
        }
        
        addStackView(theme)
    }
    
    private func addStackView(_ theme: PassphraseVerifyCardViewTheme) {
        stackView.alignment = .fill
        stackView.spacing = theme.stackViewSpacing
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(theme.stackViewSpacing)
        }

        addMnemonicLabel(theme, firstMnemonicLabel, tag: 0)
        addMnemonicLabel(theme, secondMnemonicLabel, tag: 1)
        addMnemonicLabel(theme, thirdMnemonicLabel, tag: 2)
    }
    
    private func addMnemonicLabel(
        _ theme: PassphraseVerifyCardViewTheme,
        _ mnemonicLabel: Label,
        tag: Int
    ) {
        mnemonicLabel.tag = tag
        mnemonicLabel.contentEdgeInsets = theme.mnemonicLabelContentInset
        mnemonicLabel.customizeAppearance(theme.mnemonicLabel)
        mnemonicLabel.draw(corner: theme.mnemonicLabelCorner)
        
        stackView.addArrangedSubview(mnemonicLabel)
    }
}

protocol PassphraseVerifyCardViewDelegate: AnyObject {
    func passphraseVerifyCardViewDidSelectWord(
        _ passphraseVerifyCardView: PassphraseVerifyCardView,
        item: Int
    )
}
