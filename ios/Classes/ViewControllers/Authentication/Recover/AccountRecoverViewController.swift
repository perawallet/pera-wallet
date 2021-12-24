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
//  AccountRecoverViewController.swift

import UIKit
import SVProgressHUD

class AccountRecoverViewController: BaseScrollViewController {

    private let layout = Layout<LayoutConstants>()

    private lazy var optionsModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.optionsModalHeight))
    )

    private lazy var inputSuggestionsViewController: InputSuggestionViewController = {
        let inputSuggestionViewController = InputSuggestionViewController(configuration: configuration)
        inputSuggestionViewController.view.frame = layout.current.inputSuggestionsFrame
        return inputSuggestionViewController
    }()

    private var keyboardController = KeyboardController()
    
    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 338.0))
    )
    
    private lazy var accountRecoverView = AccountRecoverView()

    private lazy var recoverButton = MainButton(title: "recover-title".localized)

    private var isRecoverEnabled: Bool {
        return getMnemonics() != nil
    }
    
    private lazy var accountManager: AccountManager? = {
        guard let api = self.api else {
            return nil
        }
        let manager = AccountManager(api: api)
        return manager
    }()

    private lazy var dataController: AccountRecoverDataController = {
        guard let session = self.session else {
            fatalError("Session should be set")
        }
        let dataController = AccountRecoverDataController(session: session)
        return dataController
    }()

    private var recoverInputViews: [RecoverInputView] {
        return accountRecoverView.recoverInputViews
    }

    private let accountSetupFlow: AccountSetupFlow
    
    init(accountSetupFlow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        accountRecoverView.currentInputView?.beginEditing()
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "recover-from-seed-title".localized
        recoverButton.isEnabled = false
    }

    override func linkInteractors() {
        super.linkInteractors()
        accountRecoverView.delegate = self
        dataController.delegate = self
        keyboardController.dataSource = self
        inputSuggestionsViewController.delegate = self
    }

    override func setListeners() {
        super.setListeners()
        keyboardController.beginTracking()
        setKeyboardNotificationListeners()
        recoverButton.addTarget(self, action: #selector(triggerRecoverAction), for: .touchUpInside)
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupAccountRecoverViewLayout()
        setupRecoverButtonLayout()
    }
}

extension AccountRecoverViewController {
    private func setupAccountRecoverViewLayout() {
        contentView.addSubview(accountRecoverView)
        
        accountRecoverView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.inputViewHeight)
            make.bottom.equalToSuperview()
        }
    }

    private func setupRecoverButtonLayout() {
        view.addSubview(recoverButton)

        recoverButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview().inset(layout.current.defaultInset + view.safeAreaBottom)
        }
    }
}

extension AccountRecoverViewController {
    private func setKeyboardNotificationListeners() {
        keyboardController.notificationHandlerWhenKeyboardShown = { keyboard in
            self.updateRecoverButtonLayoutWhenKeyboardIsShown(keyboard)
        }

        keyboardController.notificationHandlerWhenKeyboardHidden = { _ in
            self.updateRecoverButtonLayoutWhenKeyboardIsHidden()
        }
    }

    private func updateRecoverButtonLayoutWhenKeyboardIsShown(_ keyboard: KeyboardController.UserInfo) {
        recoverButton.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.defaultInset + keyboard.height)
        }
    }

    private func updateRecoverButtonLayoutWhenKeyboardIsHidden() {
        recoverButton.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.defaultInset + view.safeAreaBottom)
        }
    }
}

extension AccountRecoverViewController {
    @objc
    private func triggerRecoverAction() {
        recoverAccount()
    }
}

extension AccountRecoverViewController {
    private func addBarButtons() {
        let optionsBarButtonItem = ALGBarButtonItem(kind: .options) { [weak self] in
            guard let self = self else {
                return
            }
            self.openRecoverOptions()
        }

        rightBarButtonItems = [optionsBarButtonItem]
    }

    private func openRecoverOptions() {
        let transitionStyle = Screen.Transition.Open.customPresent(
            presentationStyle: .custom,
            transitionStyle: nil,
            transitioningDelegate: optionsModalPresenter
        )

        let optionsViewController = open(.recoverOptions, by: transitionStyle) as? AccountRecoverOptionsViewController
        optionsViewController?.delegate = self
    }
}

extension AccountRecoverViewController: AccountRecoverOptionsViewControllerDelegate {
    func accountRecoverOptionsViewControllerDidOpenScanQR(_ viewController: AccountRecoverOptionsViewController) {
        openQRScanner()
    }

    func accountRecoverOptionsViewControllerDidPasteFromClipboard(_ viewController: AccountRecoverOptionsViewController) {
        pasteFromClipboardIfPossible()
    }

    func accountRecoverOptionsViewControllerDidOpenMoreInfo(_ viewController: AccountRecoverOptionsViewController) {
        if let url = AlgorandWeb.recoverSupport.link {
            open(url)
        }
    }
}

extension AccountRecoverViewController {
    private func openQRScanner() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displaySimpleAlertWith(title: "qr-scan-error-title".localized, message: "qr-scan-error-message".localized)
            return
        }

        let controller = open(.qrScanner(canReadWCSession: false), by: .push) as? QRScannerViewController
        controller?.delegate = self
    }

    private func recoverAccount() {
        guard let mnemonics = getMnemonics() else {
            displaySimpleAlertWith(title: "title-error".localized, message: "recover-fill-all-error".localized)
            return
        }

        view.endEditing(true)
        dataController.recoverAccount(from: mnemonics)
    }
}

extension AccountRecoverViewController {
    private func pasteFromClipboardIfPossible() {
        if let copiedText = UIPasteboard.general.string {
            updateMnemonics(copiedText)
            recoverButton.isEnabled = isRecoverEnabled
        }
    }
}

extension AccountRecoverViewController: AccountRecoverViewDelegate {
    func accountRecoverView(_ view: AccountRecoverView, didBeginEditing recoverInputView: RecoverInputView) {
        if let index = view.index(of: recoverInputView) {
            recoverInputView.bind(RecoverInputViewModel(state: .active, index: index))
        }
    }

    func accountRecoverView(_ view: AccountRecoverView, didChangeInputIn recoverInputView: RecoverInputView) {
        customizeRecoverInputViewWhenInputDidChange(recoverInputView)
    }

    private func customizeRecoverInputViewWhenInputDidChange(_ view: RecoverInputView) {
        recoverButton.isEnabled = isRecoverEnabled
        updateRecoverInputSuggestor(in: view)
        inputSuggestionsViewController.findTopSuggestions(for: view.input)
        updateRecoverInputViewStateForSuggestions(view)
    }

    private func updateRecoverInputSuggestor(in view: RecoverInputView) {
        if !view.isInputAccessoryViewSet {
            if !view.input.isNilOrEmpty {
                view.setInputAccessoryView(inputSuggestionsViewController.view)
           } else {
                view.removeInputAccessoryView()
           }
        }
    }

    private func updateRecoverInputViewStateForSuggestions(_ view: RecoverInputView) {
        guard let index = accountRecoverView.index(of: view) else {
            return
        }

        if !inputSuggestionsViewController.hasSuggestions && !view.input.isNilOrEmpty {
            view.bind(RecoverInputViewModel(state: .wrong, index: index))
        } else {
            view.bind(RecoverInputViewModel(state: .active, index: index))
        }
    }

    func accountRecoverView(_ view: AccountRecoverView, didEndEditing recoverInputView: RecoverInputView) {
        guard let index = view.index(of: recoverInputView) else {
            return
        }

        if recoverInputView.input.isNilOrEmpty {
            recoverInputView.bind(RecoverInputViewModel(state: .empty, index: index))
        } else if !hasValidSuggestion(for: recoverInputView) {
            recoverInputView.bind(RecoverInputViewModel(state: .filledWrongly, index: index))
        } else {
            recoverInputView.bind(RecoverInputViewModel(state: .filled, index: index))
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
        return isValidMnemonicInput(string)
    }
}

extension AccountRecoverViewController {
    private func hasValidSuggestion(for view: RecoverInputView) -> Bool {
        guard let input = view.input,
              !input.isEmptyOrBlank else {
            return false
        }

        return inputSuggestionsViewController.hasMatchingSuggestion(with: input)
    }

    private func isValidMnemonicInput(_ string: String) -> Bool {
        let mnemonics = string.split(separator: " ").map { String($0) }

        if containsOneMnemonic(mnemonics) {
            return string != " "
        }

        // If copied text is a valid mnemonc, fill automatically.
        if isValidMnemonicCount(mnemonics) {
            fillMnemonics(mnemonics)
            recoverButton.isEnabled = true
            return false
        }

        // Invalid copy/paste action for mnemonics.
        NotificationBanner.showError("title-error".localized, message: "recover-copy-error".localized)
        return false
    }

    private func containsOneMnemonic(_ mnemonics: [String]) -> Bool {
        return mnemonics.count <= 1
    }

    private func isValidMnemonicCount(_ mnemonics: [String]) -> Bool {
        return mnemonics.count == AccountRecoverView.Constants.totalMnemonicCount
    }
}

extension AccountRecoverViewController {
    private func getMnemonics() -> String? {
        let inputs = recoverInputViews.compactMap { $0.input }.filter { !$0.isEmpty }
        if inputs.count == AccountRecoverView.Constants.totalMnemonicCount {
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
        if !hasValidSuggestion(for: recoverInputView) {
            return
        }

        recoverInputView.removeInputAccessoryView()

        if let nextInputView = recoverInputViews.nextView(of: recoverInputView) as? RecoverInputView {
            nextInputView.beginEditing()
            return
        }

        recoverAccount()
    }
}

extension AccountRecoverViewController {
    private func updateMnemonics(_ text: String) {
        let mnemonics = text.split(separator: " ").map { String($0) }

        if containsOneMnemonic(mnemonics) {
            if let firstText = mnemonics[safe: 0],
               !firstText.trimmed.isEmpty {
                updateCurrentInputView(with: text)
            }
            return
        }

        // If copied text is a valid mnemonic, fill automatically.
        if isValidMnemonicCount(mnemonics) {
            fillMnemonics(mnemonics)
            recoverButton.isEnabled = true
            return
        }

        // Invalid copy/paste action for mnemonics.
        NotificationBanner.showError("title-error".localized, message: "recover-copy-error".localized)
    }
}

extension AccountRecoverViewController: AccountRecoverDataControllerDelegate {
    func accountRecoverDataController(
        _ accountRecoverDataController: AccountRecoverDataController,
        didRecover account: AccountInformation
    ) {
        log(RegistrationEvent(type: .recover))
        openSuccessfulRecoverModal(for: account)
    }

    func accountRecoverDataController(
        _ accountRecoverDataController: AccountRecoverDataController,
        didFailRecoveringWith error: AccountRecoverDataController.RecoverError
    ) {
        displayRecoverError(error)
    }

    private func openSuccessfulRecoverModal(for recoveredAccount: AccountInformation) {
        let configurator = BottomInformationBundle(
            title: "recover-from-seed-verify-pop-up-title".localized,
            image: img("img-green-checkmark"),
            explanation: "recover-from-seed-verify-pop-up-explanation".localized,
            actionTitle: "title-go-home".localized,
            actionImage: img("bg-main-button")) {
                self.launchHome(with: recoveredAccount)
        }

        open(
            .bottomInformation(mode: .confirmation, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: bottomModalPresenter
            )
        )
    }

    private func launchHome(with account: AccountInformation) {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        accountManager?.fetchAllAccounts(isVerifiedAssetsIncluded: true) {
            SVProgressHUD.showSuccess(withStatus: "title-done".localized)
            SVProgressHUD.dismiss(withDelay: 1.0) {
                switch self.accountSetupFlow {
                case .initializeAccount:
                    DispatchQueue.main.async {
                        self.dismiss(animated: false) {
                            UIApplication.shared.rootViewController()?.setupTabBarController()
                        }
                    }
                case .addNewAccount:
                    self.closeScreen(by: .dismiss, animated: false)
                case .none:
                    break
                }
            }
        }
    }

    private func displayRecoverError(_ error: AccountRecoverDataController.RecoverError) {
        switch error {
        case .alreadyExist:
            NotificationBanner.showError("title-error".localized, message: "recover-from-seed-verify-exist-error".localized)
        case .invalid:
            NotificationBanner.showError(
                "passphrase-verify-invalid-title".localized,
                message: "pass-phrase-verify-invalid-passphrase".localized
            )
        case .sdk:
            NotificationBanner.showError("title-error".localized, message: "pass-phrase-verify-sdk-error".localized)
        }
    }
}

extension AccountRecoverViewController: InputSuggestionViewControllerDelegate {
    func inputSuggestionViewController(_ inputSuggestionViewController: InputSuggestionViewController, didSelect mnemonic: String) {
        updateCurrentInputView(with: mnemonic)
    }
}

extension AccountRecoverViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {
        guard qrText.mode == .mnemonic else {
            displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-mnemonics-message".localized) { _ in
                if let handler = completionHandler {
                    handler()
                }
            }
            
            return
        }

        updateScreenFromQR(with: qrText)
    }

    private func updateScreenFromQR(with qrText: QRText) {
        let mnemonics = qrText.qrText().split(separator: " ").map { String($0) }
        fillMnemonics(mnemonics)
        recoverButton.isEnabled = true
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = completionHandler {
                handler()
            }
        }
    }
}

extension AccountRecoverViewController: KeyboardControllerDataSource {
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat {
        return layout.current.keyboardInset
    }

    func firstResponder(for keyboardController: KeyboardController) -> UIView? {
        return accountRecoverView.currentInputView
    }

    func containerView(for keyboardController: KeyboardController) -> UIView {
        return contentView
    }

    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat {
        return layout.current.defaultInset
    }
}

extension AccountRecoverViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 20.0
        let inputSuggestionsFrame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 44.0)
        let keyboardInset: CGFloat = 92.0
        let inputViewHeight: CGFloat = 732.0
        let optionsModalHeight: CGFloat = 294.0
    }
}
