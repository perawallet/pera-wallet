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
//  SendAssetTransactionPreviewViewController.swift

import UIKit
import SnapKit
import SVProgressHUD

class SendAssetTransactionPreviewViewController: SendTransactionPreviewViewController, TestNetTitleDisplayable {
    
    private lazy var assetSupportPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 422.0))
    )

    private lazy var maxTransactionWarningPresenter: CardModalPresenter = {
        let screenHeight = UIScreen.main.bounds.height
        let height = screenHeight <= 522.0 ? screenHeight - 20.0 : 522.0
        return CardModalPresenter(
            config: ModalConfiguration(
                animationMode: .normal(duration: 0.25),
                dismissMode: .scroll
            ),
            initialModalSize: .custom(CGSize(width: view.frame.width, height: height))
        )
    }()
    
    private lazy var bottomInformationPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 422.0))
    )
    
    weak var delegate: SendAssetTransactionPreviewViewControllerDelegate?
    
    private let assetDetail: AssetDetail
    private var isForcedMaxTransaction = false
    private let viewModel: SendAssetTransactionPreviewViewModel
    
    override var filterOption: SelectAssetViewController.FilterOption {
        return .asset(assetDetail: assetDetail)
    }
    
    init(
        account: Account?,
        assetReceiverState: AssetReceiverState,
        assetDetail: AssetDetail,
        isSenderEditable: Bool,
        isMaxTransaction: Bool,
        qrText: QRText?,
        configuration: ViewControllerConfiguration
    ) {
        self.assetDetail = assetDetail
        self.isForcedMaxTransaction = isMaxTransaction
        viewModel = SendAssetTransactionPreviewViewModel(
            assetDetail: assetDetail,
            isForcedMaxTransaction: isMaxTransaction,
            isAccountSelectionEnabled: isSenderEditable
        )
        super.init(
            account: account,
            assetReceiverState: assetReceiverState,
            isSenderEditable: isSenderEditable,
            qrText: qrText,
            configuration: configuration
        )
        self.assetFraction = assetDetail.fractionDecimals
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        viewModel.configure(sendTransactionPreviewView, with: selectedAccount)
        configureTransactionReceiver()
        displayTestNetTitleView(with: "title-send".localized + " \(assetDetail.getDisplayNames().0)")
    }
    
    override func configure(forSelected account: Account, with assetDetail: AssetDetail?) {
        selectedAccount = account
        viewModel.configure(sendTransactionPreviewView, with: selectedAccount)
        sendTransactionPreviewView.setAssetSelectionHidden(true)
    }
    
    override func presentAccountList(accountSelectionState: AccountSelectionState) {
        let accountListViewController = open(
            .accountList(
                mode: accountSelectionState == .sender ?
                    .transactionSender(assetDetail: assetDetail) :
                    .transactionReceiver(assetDetail: assetDetail)
            ),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: accountListModalPresenter
            )
        ) as? AccountListViewController
    
        accountListViewController?.delegate = self
    }
    
    override func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        guard let assetTransactionDraft = draft as? AssetTransactionSendDraft else {
            return
        }
        
        let controller = open(
            .sendAssetTransaction(
                assetTransactionSendDraft: assetTransactionDraft,
                transactionController: transactionController,
                receiver: assetReceiverState,
                isSenderEditable: isSenderEditable
            ),
            by: .push
        )
        (controller as? SendTransactionViewController)?.delegate = self
    }
    
    override func sendTransactionPreviewViewDidTapMaxButton(_ sendTransactionPreviewView: SendTransactionPreviewView) {
        sendTransactionPreviewView.amountInputView.inputTextField.text = selectedAccount?.amountDisplayWithFraction(for: assetDetail)
    }
    
    override func displayTransactionPreview() {
        if selectedAccount == nil {
            displaySimpleAlertWith(title: "send-algos-alert-incomplete-title".localized, message: "send-algos-alert-message".localized)
            return
        }
        
        switch assetReceiverState {
        case let .contact(contact):
            if let address = contact.address {
                checkIfAddressIsValidForTransaction(address)
            }
        case .myAccount:
            validateTransaction()
        default:
            let address = sendTransactionPreviewView.transactionReceiverView.addressText
            if !address.isEmpty {
                assetReceiverState = .address(address: address, amount: nil)
                checkIfAddressIsValidForTransaction(address)
                return
            } else {
                displaySimpleAlertWith(
                    title: "send-algos-alert-incomplete-title".localized,
                    message: "send-algos-alert-message-address".localized
                )
            }
        }
    }
    
    override func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {
        guard let qrAddress = qrText.address else {
            return
        }
        
        sendTransactionPreviewView.transactionReceiverView.state = .address(address: qrAddress, amount: nil)
        assetReceiverState = .address(address: qrAddress, amount: nil)
        if let qrAmount = qrText.amount {
            displayQRAlert(for: qrAmount, to: qrAddress, with: qrText.asset)
        }

        if let lockedNote = qrText.lockedNote,
           !lockedNote.isEmpty {
            sendTransactionPreviewView.noteInputView.value = lockedNote
            sendTransactionPreviewView.noteInputView.setEnabled(false)
        } else if let note = qrText.note,
           !note.isEmpty {
            sendTransactionPreviewView.noteInputView.value = note
            sendTransactionPreviewView.noteInputView.setEnabled(true)
        }
        
        if let qrAsset = qrText.asset {
            let qrAssetText = "\(qrAsset)"
            
            if !isAccountContainsAsset(qrAssetText) {
                presentAssetNotSupportedAlert(receiverAddress: qrText.address)
                
                if let handler = completionHandler {
                    handler()
                }
                
                return
            }
            
            if qrAssetText != "\(assetDetail.id)" {
                displaySimpleAlertWith(title: "asset-support-not-same-title".localized, message: "asset-support-not-same-error".localized)
                
                if let handler = completionHandler {
                    handler()
                }
                
                return
            }
        }
    }
    
    private func isAccountContainsAsset(_ assetIndex: String) -> Bool {
        guard let selectedAccount = selectedAccount else {
            return false
        }
        
        var isAssetAddedToAccount = false
        
        for _ in selectedAccount.assetDetails where "\(assetDetail.id)" == assetIndex {
            isAssetAddedToAccount = true
            break
        }
        
        return isAssetAddedToAccount
    }
    
    override func updateSelectedAccountForSender(_ account: Account) {
        viewModel.update(sendTransactionPreviewView, with: account, isMaxTransaction: isMaxTransaction)
    }
    
    private func displayQRAlert(for qrAmount: UInt64, to qrAddress: String, with assetId: Int64?) {
        let configurator = BottomInformationBundle(
            title: "send-qr-scan-alert-title".localized,
            image: img("icon-qr-alert"),
            explanation: "send-qr-scan-alert-message".localized,
            actionTitle: "title-approve".localized) {
                if self.assetDetail.id == assetId {
                    let amountValue = qrAmount.assetAmount(fromFraction: self.assetDetail.fractionDecimals)
                    let amountText = amountValue.toFractionStringForLabel(fraction: self.assetDetail.fractionDecimals)
                    
                    self.sendTransactionPreviewView.transactionReceiverView.state = .address(address: qrAddress, amount: amountText)
                    self.assetReceiverState = .address(address: qrAddress, amount: amountText)
                    
                    self.amount = amountValue
                    self.sendTransactionPreviewView.amountInputView.inputTextField.text = amountText
                    return
                }
                
                self.displaySimpleAlertWith(title: "", message: "send-qr-different-asset-alert".localized)
                self.sendTransactionPreviewView.transactionReceiverView.state = .address(address: qrAddress, amount: nil)
                self.assetReceiverState = .address(address: qrAddress, amount: nil)
                return
        }
        
        open(
            .bottomInformation(mode: .qr, configurator: configurator),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: bottomInformationPresenter
            )
        )
    }
}

extension SendAssetTransactionPreviewViewController {
    private func checkIfAddressIsValidForTransaction(_ address: String) {
        guard let selectedAccount = selectedAccount else {
            return
        }
        
        if !AlgorandSDK().isValidAddress(address) {
            NotificationBanner.showError("title-error".localized, message: "send-algos-receiver-address-validation".localized)
            return
        }
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        api?.fetchAccount(with: AccountFetchDraft(publicKey: address)) { fetchAccountResponse in
            switch fetchAccountResponse {
            case let .success(receiverAccountWrapper):
                if !receiverAccountWrapper.account.isSameAccount(with: address) {
                    self.dismissProgressIfNeeded()
                    UIApplication.shared.firebaseAnalytics?.record(
                        MismatchAccountErrorLog(requestedAddress: address, receivedAddress: receiverAccountWrapper.account.address)
                    )
                    return
                }

                receiverAccountWrapper.account.assets = receiverAccountWrapper.account.nonDeletedAssets()
                let receiverAccount = receiverAccountWrapper.account
                if !selectedAccount.requiresLedgerConnection() {
                    self.dismissProgressIfNeeded()
                }
                
                if let assets = receiverAccount.assets {
                    if assets.contains(where: { asset -> Bool in
                        self.assetDetail.id == asset.id
                    }) {
                        self.validateTransaction()
                    } else {
                        self.presentAssetNotSupportedAlert(receiverAddress: address)
                    }
                } else {
                    self.presentAssetNotSupportedAlert(receiverAddress: address)
                }
            case let .failure(error, _):
                if error.isHttpNotFound {
                    if !selectedAccount.requiresLedgerConnection() {
                        self.dismissProgressIfNeeded()
                    }
                    self.presentAssetNotSupportedAlert(receiverAddress: address)
                } else {
                    self.dismissProgressIfNeeded()
                }
            }
        }
    }
    
    private func presentAssetNotSupportedAlert(receiverAddress: String?) {
        let assetAlertDraft = AssetAlertDraft(
            account: selectedAccount,
            assetIndex: assetDetail.id,
            assetDetail: assetDetail,
            title: "asset-support-title".localized,
            detail: "asset-support-error".localized,
            actionTitle: "title-ok".localized
        )
        
        if let receiverAddress = receiverAddress,
            let senderAddress = selectedAccount?.address {
            let draft = AssetSupportDraft(
                sender: senderAddress,
                receiver: receiverAddress,
                assetId: assetDetail.id
            )
            api?.sendAssetSupportRequest(with: draft)
        }
        
        self.open(
            .assetSupport(assetAlertDraft: assetAlertDraft),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: assetSupportPresenter
            )
        )
    }
    
    private func validateTransaction() {
        if let amountText = sendTransactionPreviewView.amountInputView.inputTextField.text,
           let decimalAmount = amountText.decimalAmount {
            amount = decimalAmount
        }
            
        if !isTransactionValid() {
            displaySimpleAlertWith(
                title: "send-algos-alert-incomplete-title".localized,
                message: "send-algos-alert-message-address".localized
            )
            return
        }
        
        guard let assetAmount = selectedAccount?.amount(for: assetDetail) else {
            return
        }
        
        if assetAmount < amount {
            self.displaySimpleAlertWith(title: "title-error".localized, message: "send-asset-amount-error".localized)
            return
        }

        composeTransactionData()
    }
    
    private func composeTransactionData() {
        guard let selectedAccount = selectedAccount,
            let toAccount = getReceiverAccount()?.address else {
            return
        }

        SVProgressHUD.show(withStatus: "title-loading".localized)
        
        transactionController.delegate = self
        let transaction = AssetTransactionSendDraft(
            from: selectedAccount,
            toAccount: toAccount,
            amount: amount,
            assetIndex: assetDetail.id,
            assetDecimalFraction: assetDetail.fractionDecimals,
            isVerifiedAsset: assetDetail.isVerified,
            note: getNoteText()
        )
               
        transactionController.setTransactionDraft(transaction)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetTransaction)
        
        if selectedAccount.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }
}

extension SendAssetTransactionPreviewViewController {
    private func configureTransactionReceiver() {
        switch assetReceiverState {
        case .initial:
            amount = 0.00
            sendTransactionPreviewView.transactionReceiverView.state = assetReceiverState
        case let .address(_, amount):
            if let sendAmount = amount,
                let amountInt = UInt64(sendAmount) {
                self.amount = amountInt.assetAmount(fromFraction: assetDetail.fractionDecimals)
                sendTransactionPreviewView.amountInputView.inputTextField.text
                    = self.amount.toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
            }
            sendTransactionPreviewView.transactionReceiverView.state = assetReceiverState
        case .myAccount, .contact:
            sendTransactionPreviewView.transactionReceiverView.state = assetReceiverState
        }
    }
}

extension SendAssetTransactionPreviewViewController: SendTransactionViewControllerDelegate {
    func sendTransactionViewController(_ viewController: SendTransactionViewController, didCompleteTransactionFor asset: Int64?) {
        delegate?.sendAssetTransactionPreviewViewController(self, didCompleteTransactionFor: assetDetail)
    }
}

protocol SendAssetTransactionPreviewViewControllerDelegate: AnyObject {
    func sendAssetTransactionPreviewViewController(
        _ viewController: SendAssetTransactionPreviewViewController,
        didCompleteTransactionFor assetDetail: AssetDetail
    )
}
