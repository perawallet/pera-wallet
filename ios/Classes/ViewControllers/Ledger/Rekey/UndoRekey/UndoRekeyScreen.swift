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

//   UndoRekeyScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class UndoRekeyScreen:
    ScrollScreen,
    NavigationBarLargeTitleConfigurable,
    TransactionControllerDelegate {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    var navigationBarScrollView: UIScrollView {
        return scrollView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private(set) lazy var navigationBarLargeTitleController = NavigationBarLargeTitleController(screen: self)
    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = createNavigationBarLargeTitleView()

    private lazy var bodyView = ALGActiveLabel()
    private lazy var summaryView = RekeyInfoView()
    private lazy var informationContentView = MacaroonUIKit.VStackView()
    private lazy var primaryActionView = MacaroonUIKit.Button()

    private lazy var transitionToUndoRekeyConfirmation = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToLedgerConnection = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToLedgerConnectionIssuesWarning = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToSignWithLedgerProcess = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private lazy var transactionController: TransactionController = {
        return TransactionController(
            api: api!,
            sharedDataController: sharedDataController,
            bannerController: bannerController,
            analytics: analytics
        )
    }()

    private lazy var currencyFormatter = CurrencyFormatter()

    private let theme: UndoRekeyScreenTheme
    private let session: Session
    private let sharedDataController: SharedDataController
    private let bannerController: BannerController
    private let loadingController: LoadingController
    private let analytics: ALGAnalytics
    
    private let sourceAccount: Account
    private let authAccount: Account
    private let newAuthAccount: Account

    init(
        sourceAccount: Account,
        authAccount: Account,
        newAuthAccount: Account,
        theme: UndoRekeyScreenTheme = .init(),
        api: ALGAPI,
        session: Session,
        sharedDataController: SharedDataController,
        bannerController: BannerController,
        loadingController: LoadingController,
        analytics: ALGAnalytics
    ) {
        self.sourceAccount = sourceAccount
        self.authAccount = authAccount
        self.newAuthAccount = newAuthAccount
        self.theme = theme
        self.session = session
        self.sharedDataController = sharedDataController
        self.bannerController = bannerController
        self.loadingController = loadingController
        self.analytics = analytics
        super.init(api: api)
    }

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        navigationItem.largeTitleDisplayMode = .never
        navigationBarLargeTitleController.title = "title-undo-rekey-capitalized-sentence".localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    override func linkInteractors() {
        super.linkInteractors()

        navigationBarLargeTitleController.activate()

        transactionController.delegate = self
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

    /// <mark>
    /// UIScrollViewDelegate
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        navigationBarLargeTitleController.scrollViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset,
            contentOffsetDeltaYBelowLargeTitle: 0
        )
    }
}

extension UndoRekeyScreen {
    private func addUI() {
        addBackground()
        addNavigationBarLargeTitle()
        addBody()
        addSummary()
        addInformationContent()
        addPrimaryAction()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addNavigationBarLargeTitle() {
        contentView.addSubview( navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.setPaddings(theme.navigationBarEdgeInset)
        }
    }

    private func addBody() {
        bodyView.customizeAppearance(theme.body)

        contentView.addSubview(bodyView)
        bodyView.snp.makeConstraints {
            $0.top == navigationBarLargeTitleView.snp.bottom + theme.spacingBetweenTitleAndBody
            $0.leading == theme.bodyHorizontalEdgeInsets.leading
            $0.trailing == theme.bodyHorizontalEdgeInsets.trailing
        }

        bindBody()
    }

    private func addSummary() {
        summaryView.customize(theme.summary)

        contentView.addSubview(summaryView)
        summaryView.snp.makeConstraints {
            $0.top == bodyView.snp.bottom + theme.spacingBetweenBodyAndSummary
            $0.leading == theme.summaryHorizontalEdgeInsets.leading
            $0.bottom == 0
            $0.trailing == theme.summaryHorizontalEdgeInsets.trailing
        }

        bindSummary()
    }

    private func addInformationContent() {
        footerView.addSubview(informationContentView)
        informationContentView.spacing = theme.spacingBetweenInformationItems
        informationContentView.snp.makeConstraints {
            $0.top == theme.informationContentEdgeInsets.top
            $0.leading == theme.informationContentEdgeInsets.leading
            $0.trailing == theme.informationContentEdgeInsets.trailing
        }

        addCurrentlyRekeyed()
        addTransactionFee()
    }

    private func addPrimaryAction() {
        primaryActionView.customizeAppearance(theme.primaryAction)
        primaryActionView.contentEdgeInsets = theme.primaryActionContentEdgeInsets

        footerView.addSubview(primaryActionView)
        primaryActionView.snp.makeConstraints {
            $0.top == informationContentView.snp.bottom + theme.primaryActionEdgeInsets.top
            $0.leading == theme.primaryActionEdgeInsets.leading
            $0.trailing == theme.primaryActionEdgeInsets.trailing
            $0.bottom == theme.primaryActionEdgeInsets.bottom
        }

        primaryActionView.addTouch(
            target: self,
            action: #selector(performPrimaryAction)
        )

        bindPrimaryAction()
    }
}

extension UndoRekeyScreen {
    private func addCurrentlyRekeyed() {
        let view = SecondaryListItemView()
        let theme = RekeyConfirmationInformationItemCommonTheme()
        view.customize(theme)
        informationContentView.addArrangedSubview(view)

        let viewModel = CurrentlyRekeyedAccountInformationItemViewModel(account: authAccount)
        view.bindData(viewModel)
    }

    private func addTransactionFee() {
        let view = SecondaryListItemView()
        let theme = RekeyConfirmationInformationItemCommonTheme()
        view.customize(theme)
        informationContentView.addArrangedSubview(view)

        let fee = Transaction.Constant.minimumFee
        let viewModel = TransactionFeeSecondaryListItemViewModel(fee: fee)
        view.bindData(viewModel)
    }
}

extension UndoRekeyScreen {
    private func bindBody() {
        let text =
            "undo-any-account-rekey-body"
                .localized
                .bodyRegular()

        let hyperlink: ALGActiveType =
            .word("undo-any-account-rekey-body-highlighted-text".localized)

        var attributes = Typography.bodyMediumAttributes()
        attributes.insert(.textColor(Colors.Helpers.positive.uiColor))

        bodyView.attachHyperlink(
            hyperlink,
            to: text,
            attributes: attributes
        ) {
            [unowned self] in
            self.open(AlgorandWeb.rekey.link)
        }
    }

    private func bindSummary() {
        let viewModel = UndoRekeyInfoViewModel(
            sourceAccount: sourceAccount,
            authAccount: newAuthAccount
        )
        summaryView.bindData(viewModel)
    }

    private func bindPrimaryAction() {
        primaryActionView.editTitle = .string("title-continue".localized)
    }
}

extension UndoRekeyScreen {
    @objc
    private func performPrimaryAction() {
        openUndoRekeyConfirmationScreen()
    }

    private func openUndoRekeyConfirmationScreen() {
        let eventHandler: UndoRekeyConfirmationSheet.EventHandler = {
            [weak self] event in
            guard let self else { return }
            switch event {
            case .didConfirm:
                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    performUndoRekeying()
                }
            case .didCancel:
                self.dismiss(animated: true)
            case .didTapLearnMore:
                let visibleScreen = findVisibleScreen()
                visibleScreen.open(AlgorandWeb.rekey.link)
            }
        }
        transitionToUndoRekeyConfirmation.perform(
            .undoRekeyConfirmation(
                sourceAccount: sourceAccount,
                authAccount: authAccount,
                eventHandler: eventHandler
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension UndoRekeyScreen {
    private func performUndoRekeying() {
        if !transactionController.canSignTransaction(for: sourceAccount) { return }

        loadingController.startLoadingWithMessage("title-loading".localized)

        let rekeyTransactionDraft = RekeyTransactionSendDraft(
            account: sourceAccount,
            rekeyedTo: newAuthAccount.address
        )

        transactionController.setTransactionDraft(rekeyTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .rekey)

        if sourceAccount.requiresLedgerConnection() {
            openLedgerConnection()

            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}

extension UndoRekeyScreen {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        loadingController.stopLoading()

        analytics.track(.rekeyAccount())
        saveRekeyedAccountDetails()

        eventHandler?(.didUndoRekey)
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        loadingController.stopLoading()

        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: error.asAFError?.errorDescription ?? error.localizedDescription
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        loadingController.stopLoading()

        switch error {
        case let .network(apiError):
            bannerController.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
        default:
            bannerController.presentErrorBanner(title: "title-error".localized, message: error.debugDescription)
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        ledgerConnectionScreen?.dismiss(animated: true) {
            self.ledgerConnectionScreen = nil

            self.openSignWithLedgerProcess(
                transactionController: transactionController,
                ledgerDeviceName: ledger
            )
        }
    }

    func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {
        ledgerConnectionScreen?.dismissScreen()
        ledgerConnectionScreen = nil

        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        loadingController.stopLoading()
    }

    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil
    }
}

extension UndoRekeyScreen {
    private func saveRekeyedAccountDetails() {
        guard let localAccount = session.accountInformation(from: sourceAccount.address) else {
            return
        }

        saveAccount(localAccount)
    }

    private func saveAccount(_ localAccount: AccountInformation) {
        session.authenticatedUser?.updateAccount(localAccount)
    }
}

extension UndoRekeyScreen {
    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "send-algos-minimum-amount-custom-error".localized(
                    params: amountText.someString
                )
            )
        case .invalidAddress:
            bannerController.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
        case let .sdkError(error):
            bannerController.presentErrorBanner(
                title: "title-error".localized, message: error.debugDescription
            )
        case .ledgerConnection:
            ledgerConnectionScreen?.dismiss(animated: true) {
                self.ledgerConnectionScreen = nil

                self.openLedgerConnectionIssues()
            }
        default:
            break
        }
    }
}

extension UndoRekeyScreen {
    private func openLedgerConnection() {
        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                self.transactionController.stopBLEScan()
                self.transactionController.stopTimer()

                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.loadingController.stopLoading()
            }
        }

        ledgerConnectionScreen = transitionToLedgerConnection.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
}

extension UndoRekeyScreen {
    private func openLedgerConnectionIssues() {
        transitionToLedgerConnectionIssuesWarning.perform(
            .bottomWarning(
                configurator: BottomWarningViewConfigurator(
                    image: "icon-info-green".uiImage,
                    title: "ledger-pairing-issue-error-title".localized,
                    description: .plain("ble-error-fail-ble-connection-repairing".localized),
                    secondaryActionButtonTitle: "title-ok".localized
                )
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension UndoRekeyScreen {
    private func openSignWithLedgerProcess(
        transactionController: TransactionController,
        ledgerDeviceName: String
    ) {
        let draft = SignWithLedgerProcessDraft(
            ledgerDeviceName: ledgerDeviceName,
            totalTransactionCount: 1
        )
        let eventHandler: SignWithLedgerProcessScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .performCancelApproval:
                transactionController.stopBLEScan()
                transactionController.stopTimer()

                self.signWithLedgerProcessScreen?.dismissScreen()
                self.signWithLedgerProcessScreen = nil

                self.loadingController.stopLoading()
            }
        }
        signWithLedgerProcessScreen = transitionToSignWithLedgerProcess.perform(
            .signWithLedgerProcess(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .present
        ) as? SignWithLedgerProcessScreen
    }
}

extension UndoRekeyScreen {
    func transactionController(
        _ transactionController: TransactionController,
        didCompletedTransaction id: TransactionID
    ) {}

    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController) {}

    func transactionControllerDidRejectedLedgerOperation(_ transactionController: TransactionController) {}
}

extension UndoRekeyScreen {
    enum Event {
        case didUndoRekey
    }
}
