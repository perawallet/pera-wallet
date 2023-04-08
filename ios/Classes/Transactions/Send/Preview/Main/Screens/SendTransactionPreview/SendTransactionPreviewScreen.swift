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
//   SendTransactionPreviewScreen.swift

import Foundation
import UIKit
import MacaroonUIKit

final class SendTransactionPreviewScreen: BaseScrollViewController {
   typealias EventHandler = (Event) -> Void

   override var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
      return .automatic
   }
   override var contentSizeBehaviour: BaseScrollViewController.ContentSizeBehaviour {
      return .intrinsic
   }

   var eventHandler: EventHandler?
   
   private lazy var transitionToEditNote = BottomSheetTransition(presentingViewController: self)
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

   private lazy var transactionDetailView = SendTransactionPreviewView()
   private lazy var nextButton = Button()
   private lazy var theme = Theme()

   private lazy var currencyFormatter = CurrencyFormatter()

   private var draft: TransactionSendDraft
   private lazy var transactionController = {
      guard let api = api else {
         fatalError("API should be set.")
      }
      return TransactionController(
         api: api,
         sharedDataController: sharedDataController,
         bannerController: bannerController,
         analytics: analytics
      )
   }()

   private var isLayoutFinalized = false

   init(
      draft: TransactionSendDraft,
      configuration: ViewControllerConfiguration
   ) {
      self.draft = draft
      super.init(configuration: configuration)
   }
   
   override func didTapDismissBarButton() -> Bool {
      eventHandler?(.didPerformDismiss)
      return true
   }

   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

      if !isLayoutFinalized {
         isLayoutFinalized = true
      }
   }

   override func configureAppearance() {
      super.configureAppearance()
      view.customizeBaseAppearance(backgroundColor: theme.background)
      title = "send-transaction-preview-title".localized
   }

   override func prepareLayout() {
      super.prepareLayout()
      addNextButton()
      addTransactionDetailView()
   }

   override func bindData() {
      super.bindData()

      let currency = sharedDataController.currency

      transactionDetailView.bindData(
         SendTransactionPreviewViewModel(
            draft,
            currency: currency,
            currencyFormatter: currencyFormatter
         ),
         currency: currency,
         currencyFormatter: currencyFormatter
      )
   }

   override func linkInteractors() {
      super.linkInteractors()

      transactionController.delegate = self
      nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
   }

   override func viewDidLoad() {
      super.viewDidLoad()

      fetchTransactionParams()
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

   private func fetchTransactionParams() {
      loadingController?.startLoadingWithMessage("title-loading".localized)

      sharedDataController.getTransactionParams(isCacheEnabled: true) { [weak self] paramsResult in
         guard let self else {
            return
         }

         self.loadingController?.stopLoading()

         switch paramsResult {
         case .success(let params):
            self.bindTransaction(with: params)
         case .failure(let error):
            self.bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
         }
      }
   }

   /// <todo>: Add Unit Test for composing transaction and view model changes
   private func bindTransaction(with params: TransactionParams) {
      var transactionDraft = composeTransaction()
      let builder: TransactionDataBuildable

      if transactionDraft is AlgosTransactionSendDraft {
         builder = SendAlgosTransactionDataBuilder(params: params, draft: transactionDraft, initialSize: nil)
      } else if transactionDraft is AssetTransactionSendDraft {
         builder = SendAssetTransactionDataBuilder(params: params, draft: transactionDraft)
      } else {
         return
      }

      let data = builder.composeData()

      var error: NSError?
      let json = AlgorandSDK().msgpackToJSON(data, error: &error)

      guard let jsonData = json.data(using: .utf8) else {
         return
      }

      do {
         let transactionDetail = try JSONDecoder().decode(SDKTransaction.self, from: jsonData)
         transactionDraft.fee = transactionDetail.fee

         /// <note>: When transaction detail fetched from SDK, amount will be updated as well
         /// Otherwise, amount field wouldn't be normalized with minimum balance
         /// This is only needed for Algo transaction
         if transactionDraft is AlgosTransactionSendDraft {
            transactionDraft.amount = transactionDetail.amount.toAlgos
         }

         let currency = sharedDataController.currency

         transactionDetailView.bindData(
            SendTransactionPreviewViewModel(
               transactionDraft,
               currency: currency,
               currencyFormatter: self.currencyFormatter
            ),
            currency: currency,
            currencyFormatter: self.currencyFormatter
         )
      } catch {
         self.bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
      }
   }

   private func composeTransaction() -> TransactionSendDraft {
      guard let sendTransactionDraft = draft as? SendTransactionDraft else {
         return draft
      }

      var transactionDraft: TransactionSendDraft

      switch sendTransactionDraft.transactionMode {
      case .algo:
         transactionDraft = AlgosTransactionSendDraft(
            from: draft.from,
            toAccount: draft.toAccount,
            amount: draft.amount,
            fee: nil,
            isMaxTransaction: draft.isMaxTransaction,
            identifier: nil,
            note: draft.note,
            lockedNote: draft.lockedNote
         )
         transactionDraft.toContact = draft.toContact
         transactionDraft.toNameService = draft.toNameService

      case .asset(let asset):
         var assetTransactionDraft = AssetTransactionSendDraft(
            from: draft.from,
            toAccount: draft.toAccount,
            amount: draft.amount,
            assetIndex: asset.id,
            assetDecimalFraction: asset.decimals,
            isVerifiedAsset: asset.verificationTier.isVerified,
            note: draft.note,
            lockedNote: draft.lockedNote
         )
         assetTransactionDraft.toContact = draft.toContact
         assetTransactionDraft.asset = asset
         assetTransactionDraft.toNameService = draft.toNameService

         transactionDraft = assetTransactionDraft
      }

      return transactionDraft
   }

   private func composedTransactionType(draft: TransactionSendDraft) -> TransactionController.TransactionType {
      if draft is AlgosTransactionSendDraft {
         return .algosTransaction
      } else if draft is AssetTransactionSendDraft {
         return .assetTransaction
      }

      return .algosTransaction
   }
}

extension SendTransactionPreviewScreen {
   @objc
   private func didTapNext() {
      if !transactionController.canSignTransaction(for: draft.from) { return }
      
      loadingController?.startLoadingWithMessage("title-loading".localized)

      let composedTransacation = composeTransaction()
      let transactionType = composedTransactionType(draft: composedTransacation)

      transactionController.delegate = self
      transactionController.setTransactionDraft(composedTransacation)
      transactionController.getTransactionParamsAndComposeTransactionData(for: transactionType)

      if draft.from.requiresLedgerConnection() {
         openLedgerConnection()

         transactionController.initializeLedgerTransactionAccount()
         transactionController.startTimer()
      }
   }
}

extension SendTransactionPreviewScreen {
   private func addTransactionDetailView() {
      contentView.addSubview(transactionDetailView)
      transactionDetailView.snp.makeConstraints {
         $0.top == 0
         $0.leading == 0
         $0.bottom == theme.contentBottomEdgeInset
         $0.trailing == 0
      }
      
      transactionDetailView.startObserving(event: .performEditNote) {
         [weak self] in
         guard let self = self else {
            return
         }
         
         let isLocked = self.draft.lockedNote != nil
         let editNote = self.draft.lockedNote ?? self.draft.note

         let screen: Screen = .editNote(
             note: editNote,
             isLocked: isLocked,
             delegate: self
         )

         self.transitionToEditNote.perform(
             screen,
             by: .present
         )
      }
   }

   private func addNextButton() {
      nextButton.customize(theme.nextButtonStyle)
      nextButton.bindData(ButtonCommonViewModel(title: "send-transaction-preview-button".localized))

      footerView.addSubview(nextButton)
      nextButton.snp.makeConstraints {
         $0.top == theme.nextButtonContentEdgeInsets.top
         $0.leading == theme.nextButtonContentEdgeInsets.leading
         $0.bottom == theme.nextButtonContentEdgeInsets.bottom
         $0.trailing == theme.nextButtonContentEdgeInsets.trailing
      }
   }
}

extension SendTransactionPreviewScreen: EditNoteScreenDelegate {
   func editNoteScreen(
      _ screen: EditNoteScreen,
      didUpdateNote note: String?
   ) {
      screen.closeScreen(by: .dismiss) {
          [weak self] in
          guard let self = self else {
              return
          }

         self.draft.updateNote(note)

         self.sharedDataController.getTransactionParams(isCacheEnabled: true) {
            [weak self] paramsResult in
            guard let self else {
               return
            }

            switch paramsResult {
            case .success(let params):
               self.bindTransaction(with: params)
            case .failure(let error):
               self.bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
            }
         }

         self.eventHandler?(.didEditNote(note: note))
      }
   }
}

extension SendTransactionPreviewScreen: TransactionControllerDelegate {
   func transactionController(
      _ transactionController: TransactionController,
      didFailedComposing error: HIPTransactionError
   ) {
      loadingController?.stopLoading()

      switch error {
      case .network:
         displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
      case let .inapp(transactionError):
         displayTransactionError(from: transactionError)
      }
   }

   func transactionController(
      _ transactionController: TransactionController,
      didComposedTransactionDataFor draft: TransactionSendDraft?
   ) {
      transactionController.uploadTransaction()
   }

   func transactionController(
      _ transactionController: TransactionController,
      didCompletedTransaction id: TransactionID
   ) {
      loadingController?.stopLoading()

      let controller = open(
         .transactionResult,
         by: .push
      ) as? TransactionResultScreen

      controller?.eventHandler = {
         [weak self] event in
         guard let self = self else { return }
         switch event {
         case .didCompleteTransaction:
            self.eventHandler?(.didCompleteTransaction)
         }
      }

      if draft is AlgosTransactionSendDraft || draft is AssetTransactionSendDraft {
         analytics.track(
            .completeStandardTransaction(draft: draft, transactionId: id)
         )
      }
   }

   func transactionController(
      _ transactionController: TransactionController,
      didFailedTransaction error: HIPTransactionError
   ) {
      loadingController?.stopLoading()

      switch error {
      case let .network(apiError):
         switch apiError {
         case .connection:
            displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
         default:
            bannerController?.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
         }
      default:
         bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
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

      loadingController?.stopLoading()
   }
}

extension SendTransactionPreviewScreen {
   private func displayTransactionError(from transactionError: TransactionError) {
      switch transactionError {
      case let .minimumAmount(amount):
         currencyFormatter.formattingContext = .standalone()
         currencyFormatter.currency = AlgoLocalCurrency()

         let amountText = currencyFormatter.format(amount.toAlgos)

         bannerController?.presentErrorBanner(
            title: "asset-min-transaction-error-title".localized,
            message: "send-algos-minimum-amount-custom-error".localized(
               params: amountText.someString
            )
         )
      case .invalidAddress:
         bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: "send-algos-receiver-address-validation".localized
         )
      case let .sdkError(error):
         bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: error.debugDescription
         )
      case .ledgerConnection:
         ledgerConnectionScreen?.dismiss(animated: true) {
             self.ledgerConnectionScreen = nil

             self.openLedgerConnectionIssues()
         }
      default:
         displaySimpleAlertWith(
            title: "title-error".localized,
            message: "title-internet-connection".localized
         )
      }
   }
}

extension SendTransactionPreviewScreen {
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

                self.loadingController?.stopLoading()
            }
        }

        ledgerConnectionScreen = transitionToLedgerConnection.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
}

extension SendTransactionPreviewScreen {
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

extension SendTransactionPreviewScreen {
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

               self.loadingController?.stopLoading()
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

extension SendTransactionPreviewScreen {
   enum Event {
      case didCompleteTransaction
      case didPerformDismiss
      case didEditNote(note: String?)
   }
}
