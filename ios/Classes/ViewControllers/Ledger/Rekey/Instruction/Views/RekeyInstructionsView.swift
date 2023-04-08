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
//  RekeyInstructionsView.swift

import UIKit
import MacaroonUIKit

final class RekeyInstructionsView: View {
    weak var delegate: RekeyInstructionsViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var subtitleLabel = UILabel()
    private lazy var instructionHeaderLabel = UILabel()
    private lazy var firstInstructionView = InstructionItemView()
    private lazy var secondInstructionView = InstructionItemView()
    private lazy var thirdInstructionView = InstructionItemView()
    private lazy var fourthInstructionView = InstructionItemView()
    private lazy var startButton = Button()

    func customize(_ theme: RekeyInstructionsViewTheme) {
        addTitleLabel(theme)
        addSubitleLabel(theme)
        addInstructionHeaderLabel(theme)
        addFirstInstructionView(theme)
        addSecondInstructionView(theme)
        addThirdInstructionView(theme)
        addFourthInstructionView(theme)
        addStartButton(theme)
    }

    func prepareLayout(_ layoutSheet: RekeyInstructionsViewTheme) {}

    func customizeAppearance(_ styleSheet: RekeyInstructionsViewTheme) {}
    
    func setListeners() {
        startButton.addTarget(self, action: #selector(notifyDelegateToStartRekeying), for: .touchUpInside)
    }
}

extension RekeyInstructionsView {
    @objc
    private func notifyDelegateToStartRekeying() {
        delegate?.rekeyInstructionsViewDidStartRekeying(self)
    }
}

extension RekeyInstructionsView {
    private func addTitleLabel(_ theme: RekeyInstructionsViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalToSuperview().inset(theme.titleTopPadding)
        }
    }
    
    private func addSubitleLabel(_ theme: RekeyInstructionsViewTheme) {
        subtitleLabel.customizeAppearance(theme.subtitle)

        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.subtitleTopPadding)
        }
    }
    
    private func addInstructionHeaderLabel(_ theme: RekeyInstructionsViewTheme) {
        instructionHeaderLabel.customizeAppearance(theme.headerTitle)

        addSubview(instructionHeaderLabel)
        instructionHeaderLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(theme.headerTopPadding)
        }
    }
    
    private func addFirstInstructionView(_ theme: RekeyInstructionsViewTheme) {
        firstInstructionView.customize(theme.instructionViewTheme)

        addSubview(firstInstructionView)
        firstInstructionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(instructionHeaderLabel.snp.bottom).offset(theme.firstInstructionTopPadding)
        }
    }
    
    private func addSecondInstructionView(_ theme: RekeyInstructionsViewTheme) {
        secondInstructionView.customize(theme.instructionViewTheme)

        addSubview(secondInstructionView)
        secondInstructionView.snp.makeConstraints {
            $0.leading.trailing.equalTo(firstInstructionView)
            $0.top.equalTo(firstInstructionView.snp.bottom).offset(theme.instructionSpacing)
        }
    }
    
    private func addThirdInstructionView(_ theme: RekeyInstructionsViewTheme) {
        thirdInstructionView.customize(theme.instructionViewTheme)

        addSubview(thirdInstructionView)
        thirdInstructionView.snp.makeConstraints {
            $0.leading.trailing.equalTo(firstInstructionView)
            $0.top.equalTo(secondInstructionView.snp.bottom).offset(theme.instructionSpacing)
        }
    }

    private func addFourthInstructionView(_ theme: RekeyInstructionsViewTheme) {
        fourthInstructionView.customize(theme.instructionViewTheme)

        addSubview(fourthInstructionView)
        fourthInstructionView.snp.makeConstraints {
            $0.leading.trailing.equalTo(firstInstructionView)
            $0.top.equalTo(thirdInstructionView.snp.bottom).offset(theme.instructionSpacing)
        }
    }
    
    private func addStartButton(_ theme: RekeyInstructionsViewTheme) {
        startButton.customize(theme.startButtonTheme)
        startButton.bindData(ButtonCommonViewModel(title: "rekey-instruction-start".localized))

        addSubview(startButton)
        startButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.greaterThanOrEqualTo(fourthInstructionView.snp.bottom).offset(theme.bottomPadding)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.bottomPadding)
        }
    }
}

extension RekeyInstructionsView: ViewModelBindable {
    func bindData(_ viewModel: RekeyToAnyAccountInstructionsViewModel?) {
        subtitleLabel.text = viewModel?.subtitle
        firstInstructionView.bindTitle(viewModel?.firstInstructionViewTitle)
        secondInstructionView.bindTitle(viewModel?.secondInstructionViewTitle)
        thirdInstructionView.bindTitle(viewModel?.thirdInstructionViewTitle)
        
        if let fourtItem = viewModel?.fourthInstructionViewTitle {
            fourthInstructionView.bindTitle(fourtItem)
        } else {
            fourthInstructionView.removeFromSuperview()
        }
    }
}

protocol RekeyInstructionsViewDelegate: AnyObject {
    func rekeyInstructionsViewDidStartRekeying(_ rekeyInstructionsView: RekeyInstructionsView)
}
