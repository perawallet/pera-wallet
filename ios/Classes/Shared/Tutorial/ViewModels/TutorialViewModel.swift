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
//  TutorialViewModel.swift

import UIKit
import MacaroonUIKit
import Foundation

final class TutorialViewModel: ViewModel {
    private(set) var image: UIImage?
    private(set) var title: String?
    private(set) var description: String?
    private(set) var primaryActionButtonTitle: String?
    private(set) var secondaryActionButtonTitle: String?
    private(set) var warningDescription: String?
    
    private(set) var primaryActionButtonTheme: ButtonTheme?
    private(set) var secondaryActionButtonTheme: ButtonTheme?

    init(_ model: Tutorial, theme: TutorialViewTheme) {
        bindImage(model)
        bindTitle(model)
        bindDescription(model)
        bindPrimaryActionButtonTitle(model)
        bindSecondaryActionButtonTitle(model)
        bindWarningTitle(model)
        bindButtonsStyle(model, theme: theme)
    }
}

extension TutorialViewModel {
    private func bindImage(_ tutorial: Tutorial) {
        switch tutorial {
        case .backUp:
            image = img("shield")
        case .recoverWithPassphrase:
            image = img("key")
        case .watchAccount:
            image = img("eye")
        case .writePassphrase:
            image = img("pen")
        case .passcode:
            image = img("locked")
        case .localAuthentication:
            image = img("faceid")
        case .biometricAuthenticationEnabled, .accountVerified, .ledgerSuccessfullyConnected:
            image = img("check")
        case .failedToImportLedgerAccounts:
            image = img("icon-error-close")
        case .passphraseVerified:
            image = img("shield-check")
        case .recoverWithLedger:
            image = img("ledger")
        case .collectibleTransferConfirmed:
            image = img("check")
        }
    }

    private func bindTitle(_ tutorial: Tutorial) {
        switch tutorial {
        case .backUp:
            title = "tutorial-title-back-up".localized
        case .recoverWithPassphrase:
            title = "tutorial-title-recover".localized
        case .watchAccount:
            title = "title-watch-account".localized
        case .writePassphrase:
            title = "tutorial-title-write".localized
        case .passcode:
            title = "tutorial-title-passcode".localized
        case .localAuthentication:
            title = "local-authentication-preference-title".localized
        case .biometricAuthenticationEnabled:
            title = "local-authentication-enabled-title".localized
        case .passphraseVerified:
            title = "pass-phrase-verify-pop-up-title".localized
        case .accountVerified(let flow, _):
            bindAccountSetupFlowTitle(flow)
        case .recoverWithLedger:
            title = "ledger-tutorial-title-text".localized
        case .ledgerSuccessfullyConnected:
            title = "recover-from-seed-verify-pop-up-title".localized
        case .failedToImportLedgerAccounts:
            title = "tutorial-title-failed-to-import-ledger-accounts".localized
        case .collectibleTransferConfirmed:
            title = "collectible-transfer-confirmed-title".localized
        }
    }

    private func bindDescription(_ tutorial: Tutorial) {
        switch tutorial {
        case .backUp:
            description = "tutorial-description-back-up".localized
        case .recoverWithPassphrase:
            description = "tutorial-description-recover".localized
        case .watchAccount:
            description = "tutorial-description-watch".localized
        case .writePassphrase:
            description = "tutorial-description-write".localized
        case .passcode:
            description = "tutorial-description-passcode".localized
        case .localAuthentication:
            description = "tutorial-description-local".localized
        case .biometricAuthenticationEnabled:
            description = "local-authentication-enabled-subtitle".localized
        case .passphraseVerified:
            description = "pass-phrase-verify-pop-up-explanation".localized
        case .accountVerified(let flow, _):
            bindAccountSetupFlowDescription(flow)
        case .recoverWithLedger:
            description = "tutorial-description-ledger".localized
        case .ledgerSuccessfullyConnected(let flow):
            bindAccountSetupFlowDescription(flow)
        case .failedToImportLedgerAccounts:
            description = "tutorial-description-failed-to-import-ledger-accounts".localized
        case .collectibleTransferConfirmed:
            description = "collectible-transfer-confirmed-description".localized
        }
    }

    private func bindPrimaryActionButtonTitle(_ tutorial: Tutorial) {
        switch tutorial {
        case .backUp:
            primaryActionButtonTitle = "tutorial-main-title-back-up".localized
        case .recoverWithPassphrase:
            primaryActionButtonTitle = "tutorial-main-title-recover".localized
        case .watchAccount:
            primaryActionButtonTitle = "watch-account-button".localized
        case .writePassphrase:
            primaryActionButtonTitle = "tutorial-main-title-write".localized
        case .passcode:
            primaryActionButtonTitle = "tutorial-main-title-passcode".localized
        case .localAuthentication:
            primaryActionButtonTitle = "local-authentication-enable".localized
        case .biometricAuthenticationEnabled:
            primaryActionButtonTitle = "title-go-to-accounts".localized
        case .passphraseVerified:
            primaryActionButtonTitle = "title-next".localized
        case .accountVerified(let flow, _):
            bindAccountSetupFlowPrimaryButton(flow)
        case .recoverWithLedger:
            primaryActionButtonTitle = "ledger-tutorial-title-text".localized
        case .ledgerSuccessfullyConnected(let flow):
            bindAccountSetupFlowPrimaryButton(flow)
        case .failedToImportLedgerAccounts:
            primaryActionButtonTitle = "tutorial-main-title-ledger-connected".localized
        case .collectibleTransferConfirmed:
            primaryActionButtonTitle = "collectible-transfer-confirmed-action-title".localized
        }
    }

    private func bindWarningTitle(_ tutorial: Tutorial) {
        switch tutorial {
        case .watchAccount:
            warningDescription = "tutorial-description-watch-warning".localized
        case .writePassphrase:
            warningDescription = "tutorial-description-write-warning".localized
        default:
            break
        }
    }

    private func bindSecondaryActionButtonTitle(_ tutorial: Tutorial) {
        switch tutorial {
        case .passcode:
            secondaryActionButtonTitle = "tutorial-action-title-passcode".localized
        case .localAuthentication:
            secondaryActionButtonTitle = "local-authentication-no".localized
        case .recoverWithLedger:
            secondaryActionButtonTitle = "tutorial-action-title-ledger".localized
        case .backUp(let flow, _),
             .writePassphrase(let flow, _):
            guard !flow.isBackUpAccount else { return }

            secondaryActionButtonTitle = "title-skip-for-now".localized
        case .accountVerified(let flow, _):
            bindAccountSetupFlowSecondaryButton(flow)
        case .ledgerSuccessfullyConnected(let flow):
            bindAccountSetupFlowSecondaryButton(flow)
        default:
            break
        }
    }
}

extension TutorialViewModel {
    private func bindAccountSetupFlowTitle(_ flow: AccountSetupFlow) {
        self.title = "recover-from-seed-verify-pop-up-title".localized
    }
    
    private func bindAccountSetupFlowDescription(_ flow: AccountSetupFlow) {
        if case .initializeAccount(mode: .watch) = flow {
            self.description = "recover-from-seed-verify-pop-up-description-watch-account-initialize".localized
        } else if case .addNewAccount(mode: .watch) = flow {
            self.description = "recover-from-seed-verify-pop-up-description-watch-account-add".localized
        } else {
            switch flow {
            case .initializeAccount:
                self.description = "recover-from-seed-verify-pop-up-explanation".localized
            case .addNewAccount,
                 .backUpAccount,
                 .none:
                self.description = "recover-from-seed-verify-pop-up-explanation-already-added".localized
            }
        }
    }
    
    private func bindAccountSetupFlowPrimaryButton(_ flow: AccountSetupFlow) {
        if case .initializeAccount(mode: .watch) = flow {
            self.primaryActionButtonTitle = "title-start-using-pera-wallet".localized
        } else if case .addNewAccount(mode: .watch) = flow {
            self.primaryActionButtonTitle = "title-continue".localized
        } else {
            self.primaryActionButtonTitle = "moonpay-buy-button-title".localized
        }
    }

    private func bindAccountSetupFlowSecondaryButton(_ flow: AccountSetupFlow) {
        if case .initializeAccount(mode: .watch) = flow {
            self.secondaryActionButtonTitle = nil
        } else if case .addNewAccount(mode: .watch) = flow {
            self.secondaryActionButtonTitle = nil
        } else {
            switch flow {
            case .initializeAccount:
                self.secondaryActionButtonTitle = "title-start-using-pera-wallet".localized
            case .addNewAccount,
                 .backUpAccount,
                 .none:
                self.secondaryActionButtonTitle = "title-continue".localized
            }
        }
    }

    private func bindButtonsStyle(_ tutorial: Tutorial, theme: TutorialViewTheme) {
        switch tutorial {
        case .accountVerified(let flow, _):
            bindAccountSetupFlowButtonsTheme(flow, theme: theme)
        case .ledgerSuccessfullyConnected(let flow):
            bindAccountSetupFlowButtonsTheme(flow, theme: theme)
        default:
            return
        }
    }
    
    private func bindAccountSetupFlowButtonsTheme(_ flow: AccountSetupFlow, theme: TutorialViewTheme) {
        if case .initializeAccount(mode: .watch) = flow {
            return
        } else if case .addNewAccount(mode: .watch) = flow {
            return
        } else {
            self.primaryActionButtonTheme = theme.actionButtonTheme
            self.secondaryActionButtonTheme = theme.mainButtonTheme
        }
    }
}
