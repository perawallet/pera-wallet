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
//   TutorialStepsViewController.swift

import Foundation

final class TutorialStepsViewController: BaseScrollViewController {
    private lazy var tutorialStepsView = TutorialStepsView()
    private lazy var theme = Theme()

    private let step: Troubleshoot.Step

    init(step: Troubleshoot.Step, configuration: ViewControllerConfiguration) {
        self.step = step
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "tutorial-action-title-ledger".localized

        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        contentView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        scrollView.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        tutorialStepsView.delegate = self
    }

    override func bindData() {
        super.bindData()
        tutorialStepsView.bindData(TutorialStepViewModel(step))
    }

    override func prepareLayout() {
        super.prepareLayout()
        contentView.addSubview(tutorialStepsView)
        tutorialStepsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension TutorialStepsViewController: TutorialStepsViewDelegate {
    func tutorialStepsView(_ view: TutorialStepsView, didTapURL URL: URL) {
        open(URL)
    }
}
