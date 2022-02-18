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
//   TutorialStepViewModel.swift

import MacaroonUIKit

struct Troubleshoot {
    let explanation: String
}

extension Troubleshoot {
    enum Step {
        case openApp
        case installApp
        case bluetoothConnection
        case bluetooth
    }
}

final class TutorialStepViewModel: PairedViewModel {
    private(set) var steps: [Troubleshoot]?

    init(_ model: Troubleshoot.Step) {
        bindSteps(model)
    }
}

extension TutorialStepViewModel {
    func bindSteps(_ tutorial: Troubleshoot.Step) {
        switch tutorial {
        case .openApp:
            self.steps = [
                Troubleshoot(
                    explanation: "ledger-troubleshooting-open-app-first-html".localized
                ),
                Troubleshoot(
                    explanation: "ledger-troubleshooting-open-app-second-html".localized
                )
            ]
        case .installApp:
            self.steps = [
                Troubleshoot(
                    explanation: "ledger-troubleshooting-install-app-first-html".localized
                ),
                Troubleshoot(
                    explanation: "ledger-troubleshooting-install-app-second-html".localized
                )
            ]
        case .bluetoothConnection:
            self.steps = [
                Troubleshoot(
                    explanation: "ledger-troubleshooting-bluetooth-connection-html".localized
                )
            ]

        case .bluetooth:
            self.steps = [
                Troubleshoot(
                    explanation: "ledger-troubleshooting-ledger-bluetooth-connection-guide-html".localized
                ),
                Troubleshoot(
                    explanation: "ledger-troubleshooting-ledger-bluetooth-connection-advanced-guide-html".localized
                )
            ]
        }
    }
}
