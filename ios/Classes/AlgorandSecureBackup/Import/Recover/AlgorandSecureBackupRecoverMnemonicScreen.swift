// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgorandSecureBackupRecoverMnemonicScreen.swift

import Foundation
import MacaroonForm
import MacaroonUtils
import MacaroonUIKit
import UIKit

final class AlgorandSecureBackupRecoverMnemonicScreen:
    BaseScrollViewController,
    MacaroonForm.KeyboardControllerDataSource {
    typealias EventHandler = (Event, AlgorandSecureBackupRecoverMnemonicScreen) -> Void
    var eventHandler: EventHandler?

    override var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
       return .automatic
    }
    override var contentSizeBehaviour: BaseScrollViewController.ContentSizeBehaviour {
       return .intrinsic
    }

    private lazy var inputSuggestionsViewController: InputSuggestionViewController = {
        let inputSuggestionViewController = InputSuggestionViewController(configuration: configuration)
        inputSuggestionViewController.view.frame = theme.inputSuggestionsFrame
        return inputSuggestionViewController
    }()

    private lazy var accountRecoverView = AccountRecoverView.mnemonicsForSecureBackup()
    private lazy var nextActionView = MacaroonUIKit.Button()

    private lazy var theme = AlgorandSecureBackupRecoverMnemonicScreenTheme()

    private lazy var mnemonicsParser = MnemonicsParser(wordCount: 12)

    private var isRecoverEnabled: Bool {
        return getMnemonics() != nil
    }

    private var recoverInputViews: [RecoverInputView] {
        return accountRecoverView.recoverInputViews
    }

    private lazy var keyboardController =
        MacaroonForm.KeyboardController(scrollView: scrollView, screen: self)

    private let backup: SecureBackup

    init(backup: SecureBackup, configuration: ViewControllerConfiguration) {
        self.backup = backup
        super.init(configuration: configuration)
        isAutoScrollingToEditingTextFieldEnabled = false
        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()

        accountRecoverView.currentInputView?.beginEditing()
    }

    override func linkInteractors() {
        super.linkInteractors()
       
        accountRecoverView.delegate = self
        inputSuggestionsViewController.delegate = self
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }
}

extension AlgorandSecureBackupRecoverMnemonicScreen {
    private func addUI() {
        addBackground()
        addAccountRecoverView()
        addNextAction()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addAccountRecoverView() {
        accountRecoverView.customize(theme.accountRecoverViewTheme)

        contentView.addSubview(accountRecoverView)
        accountRecoverView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.greaterThanOrEqualTo(view)
        }
    }

    private func addNextAction() {
        nextActionView.customizeAppearance(theme.nextAction)
        nextActionView.contentEdgeInsets = theme.nextActionContentEdgeInsets

        footerView.addSubview(nextActionView)
        nextActionView.snp.makeConstraints {
            $0.top == theme.nextActionEdgeInsets.top
            $0.leading == theme.nextActionEdgeInsets.leading
            $0.trailing == theme.nextActionEdgeInsets.trailing
            $0.bottom == theme.nextActionEdgeInsets.bottom
        }

        enableImport(false)
        nextActionView.addTouch(target: self, action: #selector(performNext))
    }

    private func enableImport(_ isEnabled: Bool) {
        nextActionView.isEnabled = isEnabled
    }
}

extension AlgorandSecureBackupRecoverMnemonicScreen: AccountRecoverViewDelegate {
    func accountRecoverView(_ view: AccountRecoverView, didBeginEditing recoverInputView: RecoverInputView) {
        if let index = view.index(of: recoverInputView) {
            customizeRecoverInputViewWhenInputDidChange(recoverInputView)
            recoverInputView.bindData(RecoverInputViewModel(state: .active, index: index))
        }
    }

    func accountRecoverView(_ view: AccountRecoverView, didChangeInputIn recoverInputView: RecoverInputView) {
        customizeRecoverInputViewWhenInputDidChange(recoverInputView)
    }

    private func customizeRecoverInputViewWhenInputDidChange(_ view: RecoverInputView) {
        enableImport(isRecoverEnabled)
        inputSuggestionsViewController.findTopSuggestions(for: view.input)
        updateRecoverInputSuggestor(in: view)
        updateRecoverInputViewStateForSuggestions(view)
    }

    private func updateRecoverInputSuggestor(in view: RecoverInputView) {
        if !view.isInputAccessoryViewSet {
            if !view.input.isNilOrEmpty,
               inputSuggestionsViewController.hasSuggestions {
                view.setInputAccessoryView(inputSuggestionsViewController.view)
            }
        } else {
            if !inputSuggestionsViewController.hasSuggestions || view.input.isNilOrEmpty {
                view.removeInputAccessoryView()
            }
        }
    }

    private func updateRecoverInputViewStateForSuggestions(_ view: RecoverInputView) {
        guard let index = accountRecoverView.index(of: view) else {
            return
        }

        if !inputSuggestionsViewController.hasSuggestions && !view.input.isNilOrEmpty {
            view.bindData(RecoverInputViewModel(state: .wrong, index: index))
        } else {
            view.bindData(RecoverInputViewModel(state: .active, index: index))
        }
    }

    func accountRecoverView(_ view: AccountRecoverView, didEndEditing recoverInputView: RecoverInputView) {
        guard let index = view.index(of: recoverInputView) else {
            return
        }

        if recoverInputView.input.isNilOrEmpty {
            recoverInputView.bindData(RecoverInputViewModel(state: .empty, index: index))
        } else if !hasValidSuggestion(for: recoverInputView) {
            recoverInputView.bindData(RecoverInputViewModel(state: .filledWrongly, index: index))
        } else {
            recoverInputView.bindData(RecoverInputViewModel(state: .filled, index: index))
        }
    }

    func accountRecoverView(_ view: AccountRecoverView, shouldReturn recoverInputView: RecoverInputView) -> Bool {
        finishUpdates(for: recoverInputView)
        return true
    }

    func accountRecoverView(
        _ view: AccountRecoverView,
        shouldChange recoverInputView: RecoverInputView,
        charactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        do {
            let input = recoverInputView.input.someString
            let newInput = input.replacingCharacters(
                in: range,
                with: string
            )
            let mnemonics = try mnemonicsParser.parse(newInput)

            switch mnemonics {
            case .zero:
                return true
            case .one:
                return true
            case .full(let words):
                fillMnemonics(words)
                enableImport(true)
                return false
            }
        } catch {
            /// <note>
            /// Invalid copy/paste action for mnemonics.

            return false
        }
    }
}

extension AlgorandSecureBackupRecoverMnemonicScreen {
    private func hasValidSuggestion(for view: RecoverInputView) -> Bool {
        guard let input = view.input,
              !input.isEmptyOrBlank else {
                  return false
              }

        return inputSuggestionsViewController.hasMatchingSuggestion(with: input)
    }
}

extension AlgorandSecureBackupRecoverMnemonicScreen {
    private func getMnemonics() -> String? {
        let inputs = recoverInputViews.compactMap { $0.input }.filter { !$0.isEmpty }
        if inputs.count == mnemonicsParser.wordCount {
            return inputs.joined(separator: " ")
        }
        return nil
    }

    private func fillMnemonics(_ mnemonics: [String]) {
        for (index, inputView) in recoverInputViews.enumerated() {
            inputView.setText(mnemonics[index])
        }
    }

    private func updateCurrentInputView(with mnemonic: String) {
        guard let currentInputView = accountRecoverView.currentInputView else {
            return
        }

        currentInputView.setText(mnemonic)
        finishUpdates(for: currentInputView)
    }

    private func finishUpdates(for recoverInputView: RecoverInputView) {
        if let nextInputView = recoverInputViews.nextView(of: recoverInputView) as? RecoverInputView {
            nextInputView.beginEditing()
            return
        }

    }
}

extension AlgorandSecureBackupRecoverMnemonicScreen {
    private func updateMnemonics(_ text: String) {
        do {
            let mnemonics = try mnemonicsParser.parse(text)

            switch mnemonics {
            case .zero:
                break
            case .one(let word):
                updateCurrentInputView(with: word)
            case .full(let words):
                fillMnemonics(words)
                enableImport(true)
            }
        } catch {
            /// <note>
            /// Invalid copy/paste action for mnemonics.
        }
    }
}

extension AlgorandSecureBackupRecoverMnemonicScreen: InputSuggestionViewControllerDelegate {
    func inputSuggestionViewController(_ inputSuggestionViewController: InputSuggestionViewController, didSelect mnemonic: String) {
        updateCurrentInputView(with: mnemonic)
    }
}

extension AlgorandSecureBackupRecoverMnemonicScreen {
    func keyboardController(
        _ keyboardController: MacaroonForm.KeyboardController,
        editingRectIn view: UIView
    ) -> CGRect? {
        return getEditingRectOfSearchInputField()
    }

    func bottomInsetOverKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        if let keyboard = keyboardController.keyboard {
            footerBackgroundView.snp.updateConstraints {
                $0.bottom == keyboard.height
            }

            view.layoutIfNeeded()
        }

        return spacingBetweenContentAndKeyboard()
    }

    private func spacingBetweenContentAndKeyboard() -> LayoutMetric {
        return footerView.frame.height
    }

    func bottomInsetWhenKeyboardDidHide(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        /// <note>
        /// It doesn't scroll to the bottom during the transition to another screen. When the
        /// screen is back, it will show the keyboard again anyway.
        if isViewDisappearing {
            return scrollView.contentInset.bottom
        }

        footerBackgroundView.snp.updateConstraints {
            $0.bottom == 0
        }

        view.layoutIfNeeded()

        return .zero
    }

    func spacingBetweenEditingRectAndKeyboard(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return theme.keyboardInset
    }
}

extension AlgorandSecureBackupRecoverMnemonicScreen {
    @objc
    private func performNext() {
        processSecureBackup(backup)
    }

    private func processSecureBackup(_ backup: SecureBackup) {
        guard let data = backup.cipherText else {
            presentErrorBanner()
            return
        }
        
        let algorandSDK = AlgorandSDK()
        var error: NSError?

        guard
            let mnemonics = getMnemonics(),
            let privateKey = algorandSDK.backupPrivateKey(fromMnemonic: mnemonics, error: &error),
            let cipherText = algorandSDK.generateBackupCipherKey(data: privateKey)
        else {
            presentErrorBanner()
            return
        }

        let cryptor = Cryptor(data: cipherText)
        let decryptedData = cryptor.decrypt(data: data)
        processDecryptedBackup(decryptedData)
    }

    private func processDecryptedBackup(
        _ decryptedData: Cryptor.EncryptionData
    ) {
        guard
            let data = decryptedData.data,
            let backupParameters = try? BackupParameters.decoded(data)
        else {
            presentErrorBanner()
            return
        }

        eventHandler?(.decryptedBackup(backupParameters), self)
    }

    private func presentErrorBanner() {
        bannerController?.presentErrorBanner(
            title: "algorand-secure-backup-mnemonics-error-title".localized,
            message: "algorand-secure-backup-mnemonics-error-message".localized
        )
    }
}

extension AlgorandSecureBackupRecoverMnemonicScreen {
    private func getEditingRectOfSearchInputField() -> CGRect? {
        guard let currentInputView = accountRecoverView.currentInputView else {
            return nil
        }

        return currentInputView.frame
    }
}

extension AlgorandSecureBackupRecoverMnemonicScreen {
    enum Event {
        case decryptedBackup(BackupParameters)
    }
}
