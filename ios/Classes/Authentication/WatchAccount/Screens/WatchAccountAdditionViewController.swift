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
//  WatchAccountAdditionViewController.swift

import UIKit
import MacaroonURLImage
import MacaroonForm
import MacaroonUIKit
import MacaroonUtils
import SnapKit

final class WatchAccountAdditionViewController:
    BaseScrollViewController,
    MacaroonForm.KeyboardControllerDataSource,
    NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []

    private lazy var theme = WatchAccountAdditionViewControllerTheme()

    private lazy var titleView = UILabel()
    private lazy var descriptionView = UILabel()
    private lazy var addressInputView = MultilineTextInputFieldView()
    private lazy var pasteFromClipboardActionView = MacaroonUIKit.Button()
    private lazy var nameServiceItemsContentView = MacaroonUIKit.VStackView()
    private lazy var addAccountActionView = MacaroonUIKit.Button()

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: scrollView,
        screen: self
    )

    private var pasteFromClipboardActionStartLayout: [Constraint] = []
    private var pasteFromClipboardActionEndLayout: [Constraint] = []

    private var isLayoutFinalized = false

    private var nameServiceItemsUIInteractions: [GestureInteraction] = []
    private var selectedNameService: NameService?

    private let accountSetupFlow: AccountSetupFlow
    private var address: PublicKey?
    private let dataController: WatchAccountAdditionDataController

    init(
        accountSetupFlow: AccountSetupFlow,
        address: PublicKey?,
        dataController: WatchAccountAdditionDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.accountSetupFlow = accountSetupFlow
        self.address = address
        self.dataController = dataController

        super.init(configuration: configuration)

        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addressInputView.beginEditing()
        
        displayPasteFromClipboardActionIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateUIWhenViewDidLayoutSubviews()
    }

    override func configureAppearance() {
        scrollView.contentInsetAdjustmentBehavior = .automatic
    }

    override func setListeners() {
        super.setListeners()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .willLoadNameServices: self.willLoadNameServices()
            case .didLoadNameServices(let nameServices): self.didLoadNameServices(nameServices)
            case .didFailLoadingNameServices: self.didFailLoadingNameServices()
            }
        }
    }
    
    override func prepareLayout() {
        super.prepareLayout()

        scrollView.keyboardDismissMode = .onDrag

        addUI()
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        let baseGradientColor = Colors.Defaults.background.uiColor
        backgroundGradient.colors = [
            baseGradientColor.withAlphaComponent(0),
            baseGradientColor
        ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }
}

extension WatchAccountAdditionViewController {
    private func updateUIWhenViewDidLayoutSubviews() {
        updatePasteFromClipboardActionWhenViewDidLayoutSubviews()
    }

    private func updatePasteFromClipboardActionWhenViewDidLayoutSubviews() {
        if isLayoutFinalized ||
           pasteFromClipboardActionView.bounds.isEmpty {
            return
        }

        let pasteFromClipboardActionViewRadius = pasteFromClipboardActionView.frame.height / 2
        let pasteFromClipboardActionViewCorner = Corner(radius: pasteFromClipboardActionViewRadius.ceil())
        pasteFromClipboardActionView.draw(corner: pasteFromClipboardActionViewCorner)

        isLayoutFinalized = true
    }
}

extension WatchAccountAdditionViewController {
    private func addUI() {
        addBackground()
        addTitle()
        addDescription()
        addAddressInput()
        addNameServiceItemsContent()
        addPasteFromClipboardAction()
        addAccountAction()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }
    }

    private func addDescription() {
        descriptionView.customizeAppearance(theme.description)

        contentView.addSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndDescription
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }
    }

    private func addAddressInput() {
        addressInputView.customize(theme.addressInput)

        contentView.addSubview(addressInputView)
        addressInputView.snp.makeConstraints {
            $0.top == descriptionView.snp.bottom + theme.spacingBetweenDescriptionAndAddressInput
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
            $0.greaterThanHeight(theme.addressInputMinHeight)
        }

        addressInputView.delegate = self
        addressInputView.editingDelegate = self

        bindAddressInput()

        addScanQRAction()
    }

    private func addScanQRAction() {
        let scanQRActionView = MacaroonUIKit.Button()
        scanQRActionView.customizeAppearance(theme.scanQRAction)

        addressInputView.addRightAccessoryItem(scanQRActionView)

        scanQRActionView.addTouch(
            target: self,
            action: #selector(didTapScanQR)
        )
    }

    private func addPasteFromClipboardAction() {
        pasteFromClipboardActionView.customizeAppearance(theme.pasteFromClipboardAction)
        pasteFromClipboardActionView.contentEdgeInsets = UIEdgeInsets(theme.pasteFromClipboardActionContentEdgeInsets)

        contentView.insertSubview(
            pasteFromClipboardActionView,
            belowSubview: addressInputView
        )
        pasteFromClipboardActionView.snp.makeConstraints {
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing <= theme.contentEdgeInsets.trailing
        }

        pasteFromClipboardActionView.snp.prepareConstraints {
            pasteFromClipboardActionStartLayout =  [
                $0.top == addressInputView.snp.bottom + theme.spacingBetweenAddressInputAndPasteFromClipboardAction
            ]
            pasteFromClipboardActionEndLayout = [
                $0.top == addressInputView.snp.bottom
            ]
        }

        updatePasteFromClipboardActionLayoutBeforeAnimations(isDisplaying: false)
        updatePasteFromClipboardActionAlongsideAnimations(isDisplaying: false)

        let someValidAddress = String(
            repeating: "A",
            count: validatedAddressLength
        )
        bindPasteFromClipboardAction(someValidAddress)

        pasteFromClipboardActionView.addTouch(
            target: self,
            action: #selector(didTapPasteFromClipboardAction)
        )

        observe(notification: UIPasteboard.changedNotification) {
            [weak self] _ in
            self?.displayPasteFromClipboardActionIfNeeded()
        }

        observeWhenApplicationWillEnterForeground {
            [weak self] _ in
            self?.displayPasteFromClipboardActionIfNeeded()
        }
    }

    private func addNameServiceItemsContent() {
        nameServiceItemsContentView.insetsLayoutMarginsFromSafeArea = false
        nameServiceItemsContentView.isLayoutMarginsRelativeArrangement = true

        contentView.insertSubview(
            nameServiceItemsContentView,
            belowSubview: addressInputView
        )
        nameServiceItemsContentView.snp.makeConstraints {
            $0.top == addressInputView.snp.bottom + theme.spacingBetweenAddressInputAndNameServiceContent
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
            $0.bottom == theme.contentEdgeInsets.bottom
        }
    }

    private func addAccountAction() {
        addAccountActionView.customizeAppearance(theme.addAccountAction)

        footerView.addSubview(addAccountActionView)
        addAccountActionView.contentEdgeInsets = UIEdgeInsets(theme.addAccountActionEdgeInsets)
        addAccountActionView.snp.makeConstraints {
            $0.top == theme.addAccountActionContentEdgeInsets.top
            $0.leading == theme.addAccountActionContentEdgeInsets.leading
            $0.trailing == theme.addAccountActionContentEdgeInsets.trailing
            $0.bottom == theme.addAccountActionContentEdgeInsets.bottom
        }

        addAccountActionView.addTouch(
            target: self,
            action: #selector(performAddAccount)
        )
    }
}

extension WatchAccountAdditionViewController {
    private func willLoadNameServices() {
        reset()

        addNameServiceLoadingView()
    }

    private func didLoadNameServices(_ nameServices: [NameService]) {
        reset()

        if nameServices.isEmpty {
            updateAddressInputViewInputStateForNameServicesNoContentState()
            return
        }

        addNameServiceViews(nameServices)
        animateNameServiceViews()
    }

    private func didFailLoadingNameServices() {
        reset()

        updateAddressInputViewInputStateForNameServicesLoadingFailureState()
    }
}

extension WatchAccountAdditionViewController {
    private func addNameServiceLoadingView() {
        let aView = PreviewLoadingView()
        aView.customize(theme.nameServiceLoadingTheme)

        nameServiceItemsContentView.addArrangedSubview(aView)
        aView.snp.makeConstraints {
            $0.fitToHeight(theme.nameServiceLoadingHeight)
        }

        aView.startAnimating()
    }

    private func addNameServiceViews(_ nameServices: [NameService]) {
        nameServices.forEach { nameService in
            let aView = makeNameServiceView(nameService)

            let selectionHandler = {
                [weak self] in
                guard let self = self else { return }
                self.selectedNameService = nameService

                self.addressInputView.text = nameService.address
                self.addAccountActionView.isEnabled = self.dataController.shouldEnableAddAction(self.addressInputView.text)

                self.scrollView.scrollToTop()
            }

            let interaction = GestureInteraction()
            interaction.setSelector(selectionHandler)
            interaction.attach(to: aView)
            nameServiceItemsUIInteractions.append(interaction)

            addNameServiceView(aView)
        }
    }

    private func animateNameServiceViews() {
        let animation = UIViewPropertyAnimator(
            duration: 0.25,
            curve: .easeInOut
        ) {
            [unowned self] in
            let nameServiceItemViews = nameServiceItemsContentView.arrangedSubviews
            nameServiceItemViews.forEach { view in
                view.alpha = 1
            }
        }
        animation.startAnimation()
    }
}

extension WatchAccountAdditionViewController {
    private func addNameServiceView(_ view: UIView) {
        let hasPreviousView = nameServiceItemsContentView.arrangedSubviews.last != nil

        nameServiceItemsContentView.addArrangedSubview(view)

        guard hasPreviousView else {
            return
        }

        let separator = theme.nameServiceItemSeparator
        nameServiceItemsContentView.attachSeparator(
            separator,
            to: view
        )
    }

    private func makeNameServiceView(_ nameService: NameService) -> UIView {
        let aCanvasView = UIView()

        let previewView = AccountListItemView()
        previewView.customize(theme.nameServiceTheme)

        aCanvasView.addSubview(previewView)
        previewView.snp.makeConstraints {
            $0.setPaddings(theme.nameServiceEdgeInsets)
        }

        let viewModel = makeNameServiceViewModel(nameService)
        previewView.bindData(viewModel)

        aCanvasView.alpha = 0

        return aCanvasView
    }

    private func makeNameServiceViewModel(_ nameService: NameService) -> AccountListItemViewModel {
        let nameServiceAccount = nameService.account.value
        let imageSource = DefaultURLImageSource(url: URL(string: nameService.service.logo))
        let preview = NameServiceAccountListItem(
            address: nameServiceAccount.address,
            icon: imageSource,
            title: nameServiceAccount.address.shortAddressDisplay,
            subtitle: nameService.name
        )
        let viewModel = AccountListItemViewModel(preview)
        return viewModel
    }
}

extension WatchAccountAdditionViewController {
    private func displayPasteFromClipboardActionIfNeeded() {
        let address = UIPasteboard.general.validAddress
        let shouldDisplayPasteFromClipboardAction = address != nil

        if shouldDisplayPasteFromClipboardAction {
            bindPasteFromClipboardAction(address!)
        }

        updateLayoutWhenPasteFromClipboardActionDisplayingStatusDidChange(isDisplaying: shouldDisplayPasteFromClipboardAction)
    }

    private func updateLayoutWhenPasteFromClipboardActionDisplayingStatusDidChange(isDisplaying: Bool) {
        updatePasteFromClipboardActionLayoutBeforeAnimations(isDisplaying: isDisplaying)
        updateNameServiceItemsContentLayoutWhenPasteFromClipboardActionDisplayingStatusDidChange(isDisplaying: isDisplaying)

        let animator = UIViewPropertyAnimator(
            duration: 0.25,
            curve: .easeOut
        ) { [unowned self] in
            updatePasteFromClipboardActionAlongsideAnimations(isDisplaying: isDisplaying)
            view.layoutIfNeeded()
        }
        animator.startAnimation()
    }

    func updatePasteFromClipboardActionLayoutBeforeAnimations(isDisplaying: Bool) {
        let currentLayout: [Constraint]
        let nextLayout: [Constraint]

        if isDisplaying {
            currentLayout = pasteFromClipboardActionEndLayout
            nextLayout = pasteFromClipboardActionStartLayout
        } else {
            currentLayout = pasteFromClipboardActionStartLayout
            nextLayout = pasteFromClipboardActionEndLayout
        }

        currentLayout.deactivate()
        nextLayout.activate()
    }

    func updatePasteFromClipboardActionAlongsideAnimations(isDisplaying: Bool) {
        pasteFromClipboardActionView.alpha = isDisplaying ? 1 : 0
    }

    func updateNameServiceItemsContentLayoutWhenPasteFromClipboardActionDisplayingStatusDidChange(isDisplaying: Bool) {
        let clipboardHeight = pasteFromClipboardActionView.frame.height
        let contentInsetTop = clipboardHeight + theme.spacingBetweenAddressInputAndPasteFromClipboardAction

        nameServiceItemsContentView.directionalLayoutMargins.top = isDisplaying ? contentInsetTop : .zero
    }

    @objc
    private func didTapPasteFromClipboardAction() {
        if let address = UIPasteboard.general.validAddress {
            reset()

            addressInputView.text = address
            addAccountActionView.isEnabled = dataController.shouldEnableAddAction(addressInputView.text)
        }
    }
}

extension WatchAccountAdditionViewController: FormInputFieldViewEditingDelegate {
    func formInputFieldViewDidEdit(_ view: FormInputFieldView) {
        addAccountActionView.isEnabled = dataController.shouldEnableAddAction(addressInputView.text)

        reset()

        dataController.searchNameServicesIfNeeded(for: addressInputView.text)
    }

    func formInputFieldViewDidBeginEditing(_ view: MacaroonForm.FormInputFieldView) { }

    func formInputFieldViewDidEndEditing(_ view: MacaroonForm.FormInputFieldView) { }
}

extension WatchAccountAdditionViewController: MultilineTextInputFieldViewDelegate {
    func multilineTextInputFieldViewDidReturn(_ view: MultilineTextInputFieldView) {
        performAddAccount()
    }

    func multilineTextInputFieldView(
        _ view: MultilineTextInputFieldView,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = view.text else {
            return true
        }

        let newText = text.replacingCharacters(
            in: range,
            with: string
        )

        return newText.count <= validatedAddressLength
    }
}

extension WatchAccountAdditionViewController {
    func updateAddressInputViewInputStateForNameServicesNoContentState() {
        let text: EditText = .attributedString(
            "account-not-found"
                .localized
                .bodyMedium(lineBreakMode: .byTruncatingTail)
        )
        addressInputView.inputState = .incorrect(text)
    }

    func updateAddressInputViewInputStateForNameServicesLoadingFailureState() {
        let text: EditText = .attributedString(
            "title-generic-error"
                .localized
                .bodyMedium(lineBreakMode: .byTruncatingTail)
        )
        addressInputView.inputState = .incorrect(text)
    }
}

extension WatchAccountAdditionViewController {
    private func reset() {
        func resetNameServiceItemsContent() {
            nameServiceItemsUIInteractions = []
            selectedNameService = nil

            nameServiceItemsContentView.deleteAllSubviews()
        }

        func resetAddressInputViewInputStateIfNeeded() {
            if case .incorrect = addressInputView.inputState {
                addressInputView.inputState = .focus
            }
        }

        resetNameServiceItemsContent()
        resetAddressInputViewInputStateIfNeeded()
    }
}

extension WatchAccountAdditionViewController {
    private func bindAddressInput() {
        addressInputView.text = address
        addAccountActionView.isEnabled = dataController.shouldEnableAddAction(addressInputView.text)
    }

    private func bindPasteFromClipboardAction(_ address: String) {
        let pasteText = "watch-account-paste".localized
        let addressText  = "\("(\(address.shortAddressDisplay))")"
        let text = [pasteText, addressText].joined(separator: " ")

        let attributedString =
            text
                .bodyRegular()
                .add([ .textColor(Colors.Text.white.uiColor) ])
                .addAttributes(
                    to: addressText.localized,
                    newAttributes: [
                        .textColor(Colors.Text.grayLighter.uiColor),
                        .font(Typography.footnoteMedium())
                    ]
                )

        pasteFromClipboardActionView.editTitle = .attributedString(attributedString)
    }
}

extension WatchAccountAdditionViewController {
    @objc
    private func performAddAccount() {
        addressInputView.endEditing()

        /// <todo> Refactor error handling? Move to data controller?

        guard let address = addressInputView.text,
            !address.isEmpty,
            address.isValidatedAddress else {
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "watch-account-error-address".localized
            )
            return
        }

        if sharedDataController.accountCollection[address] != nil {
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "recover-from-seed-verify-exist-error".localized
            )
            return
        }

        let account = dataController.createAccount(
            from: address,
            with: address.shortAddressDisplay
        )

        open(
            .accountNameSetup(
                flow: accountSetupFlow,
                mode: .watch,
                nameServiceName: selectedNameService?.name,
                accountAddress: account.address
            ),
            by: .push
        )
    }
}

extension WatchAccountAdditionViewController {
    @objc
    func didTapScanQR() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            displaySimpleAlertWith(
                title: "qr-scan-error-title".localized,
                message: "qr-scan-error-message".localized
            )
            return
        }
        
        let qrScannerViewController = open(
            .qrScanner(
                canReadWCSession: false
            ),
            by: .push
        ) as? QRScannerViewController
        qrScannerViewController?.delegate = self
    }
}

extension WatchAccountAdditionViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didRead qrText: QRText,
        completionHandler: EmptyHandler?
    ) {
        guard qrText.mode == .address else {
            displaySimpleAlertWith(
                title: "title-error".localized,
                message: "qr-scan-should-scan-address-message".localized
            ) { _ in
                completionHandler?()
            }
            return
        }

        reset()

        addressInputView.text = qrText.qrText()
        addAccountActionView.isEnabled = dataController.shouldEnableAddAction(addressInputView.text)
    }
    
    func qrScannerViewController(
        _ controller: QRScannerViewController,
        didFail error: QRScannerError,
        completionHandler: EmptyHandler?
    ) {
        displaySimpleAlertWith(
            title: "title-error".localized,
            message: "qr-scan-should-scan-valid-qr".localized
        ) { _ in
            completionHandler?()
        }
    }
}

extension WatchAccountAdditionViewController {
    func keyboardController(
        _ keyboardController: MacaroonForm.KeyboardController,
        editingRectIn view: UIView
    ) -> CGRect? {
        return addressInputView.frame
    }

    func bottomInsetOverKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        if let keyboard = keyboardController.keyboard {
            footerBackgroundView.snp.updateConstraints {
                $0.bottom == keyboard.height
            }

            let animator = UIViewPropertyAnimator(
                duration: keyboard.animationDuration,
                curve: keyboard.animationCurve
            ) {
                [unowned self] in
                view.layoutIfNeeded()
            }
            animator.startAnimation()
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

        let animator = UIViewPropertyAnimator(
            duration:  0.25,
            curve: .easeOut
        ) {
            [unowned self] in
            view.layoutIfNeeded()
        }
        animator.startAnimation()

        return .zero
    }
}
