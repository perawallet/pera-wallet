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

   var eventHandler: EventHandler?

   private lazy var transactionDetailView = SendTransactionPreviewView()
   private lazy var nextButtonContainer = UIView()
   private lazy var nextButton = Button()
   private lazy var theme = Theme()

   private lazy var currencyFormatter = CurrencyFormatter()

   private let draft: TransactionSendDraft
   private let transactionController: TransactionController

   private var isLayoutFinalized = false

   init(
      draft: TransactionSendDraft,
      transactionController: TransactionController,
      configuration: ViewControllerConfiguration
   ) {
      self.draft = draft
      self.transactionController = transactionController
      super.init(configuration: configuration)
   }

   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

      if !isLayoutFinalized {
         isLayoutFinalized = true

         addLinearGradient()
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
}

extension SendTransactionPreviewScreen {
   @objc
   private func didTapNext() {
      loadingController?.startLoadingWithMessage("title-loading".localized)
      transactionController.uploadTransaction()
   }
}

extension SendTransactionPreviewScreen {
   private func addTransactionDetailView() {
      contentView.addSubview(transactionDetailView)
      transactionDetailView.snp.makeConstraints {
         $0.edges.equalToSuperview()
      }
   }

   private func addNextButton() {
      view.addSubview(nextButtonContainer)
      nextButtonContainer.snp.makeConstraints {
         $0.leading.trailing.bottom.equalToSuperview()
         $0.fitToHeight(theme.linearGradientHeight + view.safeAreaBottom)
      }

      nextButton.customize(theme.nextButtonStyle)
      nextButton.bindData(ButtonCommonViewModel(title: "title-send".localized))
      nextButtonContainer.addSubview(nextButton)
      
      nextButton.snp.makeConstraints {
         $0.leading.trailing.equalToSuperview().inset(theme.nextButtonLeadingInset)
         $0.bottom.equalToSuperview().inset(theme.nextButtonBottomInset + view.safeAreaBottom)
         $0.height.equalTo(theme.nextButtonHeight)
      }
   }

   private func addLinearGradient() {
       let layer = CAGradientLayer()
       layer.frame = CGRect(
           origin: .zero,
           size: CGSize(
            width: view.bounds.width,
            height: theme.linearGradientHeight + view.safeAreaBottom
           )
       )

       let color0 = Colors.Defaults.background.uiColor.withAlphaComponent(0).cgColor
       let color1 = Colors.Defaults.background.uiColor.cgColor

       layer.colors = [color0, color1]
       nextButtonContainer.layer.insertSublayer(layer, at: 0)
   }
}

extension SendTransactionPreviewScreen: TransactionControllerDelegate {
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

   func transactionControllerDidRequestUserApprovalFromLedger(_ transactionController: TransactionController) {

   }

   func transactionControllerDidResetLedgerOperation(_ transactionController: TransactionController) {

   }
}

extension SendTransactionPreviewScreen {
    enum Event {
        case didCompleteTransaction
    }
}
