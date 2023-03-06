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
//  transactionController.swift

import MagpieHipo
import UIKit

class TransactionController {
    weak var delegate: TransactionControllerDelegate?

    private(set) var currentTransactionType: TransactionType?
    
    private var api: ALGAPI
    private let sharedDataController: SharedDataController
    private let bannerController: BannerController?
    private var params: TransactionParams?
    private var transactionDraft: TransactionSendDraft?

    private var timer: Timer?
    
    private let transactionData = TransactionData()
    
    private lazy var ledgerTransactionOperation =
        LedgerTransactionOperation(api: api, analytics: analytics)

    private lazy var transactionAPIConnector = TransactionAPIConnector(api: api, sharedDataController: sharedDataController)

    private var isLedgerRequiredTransaction: Bool {
        return transactionDraft?.from.requiresLedgerConnection() ?? false
    }

    private let analytics: ALGAnalytics
    
    init(
        api: ALGAPI,
        sharedDataController: SharedDataController,
        bannerController: BannerController?,
        analytics: ALGAnalytics
    ) {
        self.api = api
        self.sharedDataController = sharedDataController
        self.bannerController = bannerController
        self.analytics = analytics
    }
}

extension TransactionController {
    private var fromAccount: Account? {
        return transactionDraft?.from
    }

    var assetTransactionDraft: AssetTransactionSendDraft? {
        return transactionDraft as? AssetTransactionSendDraft
    }

    var algosTransactionDraft: AlgosTransactionSendDraft? {
        return transactionDraft as? AlgosTransactionSendDraft
    }

    var rekeyTransactionDraft: RekeyTransactionSendDraft? {
        return transactionDraft as? RekeyTransactionSendDraft
    }

    private var isTransactionSigned: Bool {
        return transactionData.signedTransaction != nil
    }
}

extension TransactionController {
    func setTransactionDraft(_ transactionDraft: TransactionSendDraft) {
        self.transactionDraft = transactionDraft
    }
    
    func stopBLEScan() {
        if !isLedgerRequiredTransaction {
            return
        }

        ledgerTransactionOperation.disconnectFromCurrentDevice()
        ledgerTransactionOperation.stopScan()
    }

    func startTimer() {
        if !isLedgerRequiredTransaction {
            return
        }

        ledgerTransactionOperation.delegate = self

        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            self.ledgerTransactionOperation.bleConnectionManager.stopScan()

            self.bannerController?.presentErrorBanner(
                title: "ble-error-connection-title".localized,
                message: ""
            )

            self.delegate?.transactionController(self, didFailedComposing: .inapp(.ledgerConnection))
            self.stopTimer()
        }
    }

    func stopTimer() {
        if !isLedgerRequiredTransaction {
            return
        }

        timer?.invalidate()
        timer = nil
    }

    func initializeLedgerTransactionAccount() {
        if !isLedgerRequiredTransaction {
            return
        }

        if let account = fromAccount {
            ledgerTransactionOperation.setTransactionAccount(account)
        }
    }
}

extension TransactionController {
    func getTransactionParamsAndComposeTransactionData(for transactionType: TransactionType) {
        currentTransactionType = transactionType

        transactionAPIConnector.getTransactionParams { result in
            switch result {
            case .success(let params):
                self.params = params
                self.composeTransactionData(for: transactionType)
            case .failure:
                self.resetLedgerOperationIfNeeded()

                self.delegate?.transactionController(self, didFailedComposing: .network(.connection(.init(reason: .unexpected(.unknown)))))
            }
        }
    }
    
    func uploadTransaction(with completion: EmptyHandler? = nil) {
        guard let transactionData = transactionData.signedTransaction else {
            return
        }

        transactionAPIConnector.uploadTransaction(transactionData) { transactionId, error in
            guard let id = transactionId else {
                self.resetLedgerOperationIfNeeded()
                self.logLedgerTransactionNonAcceptanceError()
                if let error = error {
                    self.delegate?.transactionController(self, didFailedTransaction: .network(.unexpected(error)))
                }
                return
            }

            completion?()
            self.delegate?.transactionController(self, didCompletedTransaction: id)
        }
    }
}

extension TransactionController {
    private func composeTransactionData(for transactionType: TransactionType, initialSize: Int? = nil) {
        switch transactionType {
        case .algosTransaction:
            let builder = SendAlgosTransactionDataBuilder(params: params, draft: algosTransactionDraft, initialSize: initialSize)
            composeTransactionData(from: builder)
        case .assetAddition:
            composeTransactionData(from: AddAssetTransactionDataBuilder(params: params, draft: assetTransactionDraft))
        case .assetRemoval:
            composeTransactionData(from: RemoveAssetTransactionDataBuilder(params: params, draft: assetTransactionDraft))
        case .assetTransaction:
            composeTransactionData(from: SendAssetTransactionDataBuilder(params: params, draft: assetTransactionDraft))
        case .rekey:
            composeTransactionData(from: RekeyTransactionDataBuilder(params: params, draft: rekeyTransactionDraft))
        }

        if transactionData.isUnsignedTransactionComposed {
            startSigningProcess(for: transactionType)
        }
    }

    private func composeTransactionData(from builder: TransactionDataBuilder) {
        builder.delegate = self

        guard let data = builder.composeData() else {
            handleMinimumAmountErrorIfNeeded(from: builder)
            resetLedgerOperationIfNeeded()
            return
        }

        updateTransactionAmount(from: builder)
        transactionData.setUnsignedTransaction(data)
    }

    private func handleMinimumAmountErrorIfNeeded(from builder: TransactionDataBuilder) {
        if let builder = builder as? SendAlgosTransactionDataBuilder,
           let minimumAccountBalance = builder.minimumAccountBalance,
           builder.calculatedTransactionAmount.unwrap(or: 0).isBelowZero {
            delegate?.transactionController(self, didFailedComposing: .inapp(TransactionError.minimumAmount(amount: minimumAccountBalance)))
        }
    }

    private func updateTransactionAmount(from builder: TransactionDataBuilder) {
        if let builder = builder as? SendAlgosTransactionDataBuilder {
            transactionDraft?.amount = builder.calculatedTransactionAmount?.toAlgos
        }
    }

    private func startSigningProcess(for transactionType: TransactionType) {
        guard let account = fromAccount else {
            return
        }

        if account.requiresLedgerConnection() {
            ledgerTransactionOperation.setUnsignedTransactionData(transactionData.unsignedTransaction)
            ledgerTransactionOperation.startScan()
        } else {
            handleStandardAccountSigning(with: transactionType)
        }
    }
}

extension TransactionController {
    private func handleStandardAccountSigning(with transactionType: TransactionType) {
        signTransactionForStandardAccount()
        
        if isTransactionSigned {
            calculateTransactionFee(for: transactionType)
            if transactionDraft?.fee == nil {
                return
            }
            
            if transactionType == .algosTransaction {
                completeAlgosTransaction()
            } else {
                completeAssetTransaction(for: transactionType)
            }
        }
    }

    private func signTransactionForStandardAccount() {
        guard let accountAddress = fromAccount?.signerAddress,
              let privateData = api.session.privateData(for: accountAddress) else {
            return
        }

        sign(privateData, with: SDKTransactionSigner())
    }

    private func sign(_ privateData: Data?, with signer: TransactionSigner) {
        signer.delegate = self

        guard let unsignedTransactionData = transactionData.unsignedTransaction,
              let signedTransaction = signer.sign(unsignedTransactionData, with: privateData) else {
            return
        }

        transactionData.setSignedTransaction(signedTransaction)
    }
}

extension TransactionController: LedgerTransactionOperationDelegate {
    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didReceiveSignature data: Data) {
        signTransactionForLedgerAccount(with: data)
    }

    private func signTransactionForLedgerAccount(with data: Data) {
        guard let transactionType = currentTransactionType,
              let account = fromAccount else {
            return
        }

        sign(data, with: LedgerTransactionSigner(account: account))
        calculateTransactionFee(for: transactionType)
        if transactionDraft?.fee != nil {
            completeLedgerTransaction(for: transactionType)
        }
    }

    private func completeLedgerTransaction(for transactionType: TransactionType) {
        if transactionType == .algosTransaction {
            completeAlgosTransaction()
        } else if transactionType == .rekey {
            completeRekeyTransaction()
        } else {
            completeAssetTransaction(for: transactionType)
        }
    }

    func ledgerTransactionOperation(_ ledgerTransactionOperation: LedgerTransactionOperation, didFailed error: LedgerOperationError) {
        switch error {
        case .cancelled:
            bannerController?.presentErrorBanner(
                title: "ble-error-transaction-cancelled-title".localized,
                message: "ble-error-fail-sign-transaction".localized
            )
        case .closedApp:
            bannerController?.presentErrorBanner(
                title: "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
        case .unmatchedAddress:
            bannerController?.presentErrorBanner(
                title: "ble-error-ledger-connection-title".localized,
                message: "ledger-transaction-account-match-error".localized
            )
        case .failedToFetchAddress:
            bannerController?.presentErrorBanner(
                title: "ble-error-transmission-title".localized,
                message: "ble-error-fail-fetch-account-address".localized
            )
        case .failedToFetchAccountFromIndexer:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "ledger-account-fetct-error".localized
            )
        case let .custom(title, message):
            bannerController?.presentErrorBanner(
                title: title,
                message: message
            )
        default:
            break
        }
    }

    func ledgerTransactionOperation(
        _ ledgerTransactionOperation: LedgerTransactionOperation,
        didRequestUserApprovalFor ledger: String
    ) {
        delegate?.transactionController(self, didRequestUserApprovalFrom: ledger)
    }

    func ledgerTransactionOperationDidRejected(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        delegate?.transactionControllerDidRejectedLedgerOperation(self)
    }

    func ledgerTransactionOperationDidFinishTimingOperation(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        stopTimer()
    }

    func ledgerTransactionOperationDidResetOperation(_ ledgerTransactionOperation: LedgerTransactionOperation) {
        delegate?.transactionControllerDidResetLedgerOperation(self)
    }
}

extension TransactionController {
    private func calculateTransactionFee(for transactionType: TransactionType) {
        let feeCalculator = TransactionFeeCalculator(
            transactionDraft: transactionDraft,
            transactionData: transactionData,
            params: params
        )
        feeCalculator.delegate = self
        let fee = feeCalculator.calculate(for: transactionType)
        if fee != nil {
            self.transactionDraft?.fee = fee
        }
    }
}

extension TransactionController {
    private func completeAlgosTransaction() {
        guard let calculatedFee = transactionDraft?.fee,
              let params = params,
              let signedTransactionData = transactionData.signedTransaction else {
            return
        }
        
        /// Re-sign transaction if the calculated fee is not matching with the projected fee
        if params.getProjectedTransactionFee(from: signedTransactionData.count) != calculatedFee {
            composeTransactionData(for: .algosTransaction, initialSize: signedTransactionData.count)
        } else {
            delegate?.transactionController(self, didComposedTransactionDataFor: self.algosTransactionDraft)
        }
    }

    private func completeAssetTransaction(for transactionType: TransactionType) {
        /// Asset addition and removal actions do not have approve part, so transaction should be completed here.
        if transactionType != .assetTransaction {
            uploadTransaction {
                self.delegate?.transactionController(self, didComposedTransactionDataFor: self.assetTransactionDraft)
            }
        } else {
            delegate?.transactionController(self, didComposedTransactionDataFor: self.assetTransactionDraft)
        }
    }

    private func completeRekeyTransaction() {
        uploadTransaction {
            self.delegate?.transactionController(self, didComposedTransactionDataFor: self.rekeyTransactionDraft)
        }
    }
}

extension TransactionController: TransactionDataBuilderDelegate {
    func transactionDataBuilder(_ transactionDataBuilder: TransactionDataBuilder, didFailedComposing error: HIPTransactionError) {
        handleTransactionComposingError(error)
    }

    private func handleTransactionComposingError(_ error: HIPTransactionError) {
        resetLedgerOperationIfNeeded()
        delegate?.transactionController(self, didFailedComposing: error)
    }
}

extension TransactionController: TransactionSignerDelegate {
    func transactionSigner(_ transactionSigner: TransactionSigner, didFailedSigning error: HIPTransactionError) {
        handleTransactionComposingError(error)
    }
}

extension TransactionController: TransactionFeeCalculatorDelegate {
    func transactionFeeCalculator(_ transactionFeeCalculator: TransactionFeeCalculator, didFailedWith minimumAmount: UInt64) {
        handleTransactionComposingError( .inapp(TransactionError.minimumAmount(amount: minimumAmount)))
    }
}

extension TransactionController {
    private func resetLedgerOperationIfNeeded() {
        if fromAccount?.requiresLedgerConnection() ?? false {
            ledgerTransactionOperation.reset()
        }
    }
}

extension TransactionController {
    private func logLedgerTransactionNonAcceptanceError() {
        guard let account = fromAccount,
              account.requiresLedgerConnection() else {
            return
        }
        
        analytics.record(
            .nonAcceptanceLedgerTransaction(account: account, transactionData: transactionData)
        )
    }
}

extension TransactionController {
    enum TransactionType {
        case algosTransaction
        case assetTransaction
        case assetAddition
        case assetRemoval
        case rekey
    }
}

/// <todo>
/// NOP! This is an informative type, shouldn't have actual data without error detail.
enum TransactionError: Error, Hashable {
    case minimumAmount(amount: UInt64)
    case invalidAddress(address: String)
    case sdkError(error: NSError?)
    case draft(draft: TransactionSendDraft?)
    case ledgerConnection
    case optOutFromCreator
    case other
}

extension TransactionError {
    func hash(
        into hasher: inout Hasher
    ) {
        switch self {
        case .minimumAmount: hasher.combine(0)
        case .invalidAddress: hasher.combine(1)
        case .sdkError: hasher.combine(2)
        case .draft: hasher.combine(3)
        case .ledgerConnection: hasher.combine(4)
        case .optOutFromCreator: hasher.combine(5)
        case .other: hasher.combine(6)
        }
    }

    static func == (
        lhs: Self,
        rhs: Self
    ) -> Bool {
        switch (lhs, rhs) {
        case (.minimumAmount, .minimumAmount): return true
        case (.invalidAddress, .invalidAddress): return true
        case (.sdkError, .sdkError): return true
        case (.draft, .draft): return true
        case (.ledgerConnection, .ledgerConnection): return true
        case (.other, .other): return true
        default: return false
        }
    }
}
