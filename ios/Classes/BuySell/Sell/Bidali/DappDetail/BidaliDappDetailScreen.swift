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

//   BidaliDappDetailScreen.swift

import Foundation
import MacaroonUtils
import WebKit

final class BidaliDappDetailScreen:
    DiscoverExternalInAppBrowserScreen,
    SharedDataControllerObserver {

    private var account: AccountHandle {
        didSet { updateBalancesIfNeeded(old: oldValue, new: account) }
    }

    private let config: BidaliConfig

    init(
        account: AccountHandle,
        config: BidaliConfig,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.config = config
        let url = URL(string: config.url)
        super.init(destination: .url(url), configuration: configuration)
        self.allowsPullToRefresh = false

        self.sharedDataController.add(self)
    }

    deinit {
        sharedDataController.remove(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addPaymentScript()
    }

    /// <note>
    /// In here, we're handling the cancel operation with assuming that confirm transaction screen is presented as modally.
    /// If presentation style changes we should handle the cancel the operation accordingly.
    override func viewDidAppearAfterInteractiveDismiss() {
        super.viewDidAppearAfterInteractiveDismiss()

        cancelPayment()
    }

    override func createUserContentController() -> InAppBrowserUserContentController {
        let controller = super.createUserContentController()
        BidaliDappDetailScriptMessage.allCases.forEach {
            controller.add(
                secureScriptMessageHandler: self,
                forMessage: $0
            )
        }
        return controller
    }

    /// <mark>
    /// WKScriptMessageHandler
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        let inAppMessage = BidaliDappDetailScriptMessage(rawValue: message.name)

        switch inAppMessage {
        case .none:
            super.userContentController(
                userContentController,
                didReceive: message
            )
        case .paymentRequest:
            handlePaymentRequestAction(message)
        case .openURLRequest:
            handleOpenURLRequestAction(message)
        }
    }
}

extension BidaliDappDetailScreen {
    private func addPaymentScript() {
        guard let script = makePaymentScript() else { return }

        userContentController.addUserScript(script)
    }

    private func makePaymentScript() -> WKUserScript? {
        let balances = makeBalances(account)

        guard let balancesJSONString = try? balances.encodedString() else {
            return nil
        }

        let script = """
            window.bidaliProvider = {
                key: '\(config.key)',
                name: '\(config.name)',
                paymentCurrencies: \(config.supportedCurrencyProtocols),
                balances: \(balancesJSONString),
                onPaymentRequest: (paymentRequest) => {
                    var payload = { data: paymentRequest };
                    window.webkit.messageHandlers.\(BidaliDappDetailScriptMessage.paymentRequest.rawValue).postMessage(JSON.stringify(payload));
                },
                openUrl: function (url) {
                    var payload = { data: { url } };
                    window.webkit.messageHandlers.\(BidaliDappDetailScriptMessage.openURLRequest.rawValue).postMessage(JSON.stringify(payload));
                }
            };
            true;
        """
        return WKUserScript(
            source: script,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
    }
}

extension BidaliDappDetailScreen {
    private func handlePaymentRequestAction(_ message: WKScriptMessage) {
        guard let jsonString = message.body as? String,
              let jsonData = jsonString.data(using: .utf8),
              let params = try? BidaliPaymentParameters.decoded(jsonData),
              let paymentRequest = params.data else {
            presentGenericErrorBanner()
            return
        }

        openPaymentRequest(paymentRequest)
    }

    private func openPaymentRequest(_ request: BidaliPaymentRequest) {
        guard let address = request.address,
              let amount = request.amount,
              let extraId = request.extraID,
              let currencyProtocol = request.currencyProtocol else {
            presentGenericErrorBanner()
            return
        }

        let asset = account.value.asset(for: currencyProtocol, network: api!.network)

        guard let asset else {
            presentGenericErrorBanner()
            return
        }

        let draft = makeSendTransactionDraft(
            from: account.value,
            to: Account(address: address),
            asset: asset,
            amount: amount,
            extraId: extraId
        )
        openPaymentRequest(draft)
    }

    private func makeSendTransactionDraft(
        from: Account,
        to: Account,
        asset: Asset,
        amount: String,
        extraId: String
    ) -> SendTransactionDraft {
        let transactionMode: TransactionMode = asset.isAlgo ? .algo : .asset(asset)
        let draft = SendTransactionDraft(
            from: from,
            toAccount: to,
            amount: NSDecimalNumber(string: amount) as Decimal,
            transactionMode: transactionMode,
            lockedNote: extraId
        )
        return draft
    }

    private func openPaymentRequest(_ draft: SendTransactionDraft) {
        let controller = open(
            .sendTransactionPreview(draft: draft),
            by: .present
        ) as? SendTransactionPreviewScreen
        controller?.navigationController?.presentationController?.delegate = self
        controller?.eventHandler = {
            [weak self] event in
            guard let self else { return }

            switch event {
            case .didCompleteTransaction:
                self.confirmPayment()
            case .didPerformDismiss:
                self.cancelPayment()
            default:
                break
            }
        }
    }
}

extension BidaliDappDetailScreen {
    private func handleOpenURLRequestAction(_ message: WKScriptMessage) {
        guard let jsonString = message.body as? String,
              let jsonData = jsonString.data(using: .utf8),
              let params = try? BidaliOpenURLParameters.decoded(jsonData),
              let openURLRequest = params.data else {
            presentGenericErrorBanner()
            return
        }

        openOpenURLRequest(openURLRequest)
    }

    private func openOpenURLRequest(_ request: BidaliOpenURLRequest) {
        guard let url = request.url.toURL() else {
            presentGenericErrorBanner()
            return
        }

        open(url)
    }
}

/// <note>: SharedDataControllerObserver
extension BidaliDappDetailScreen {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event,
           let upToDateAccount = sharedDataController.accountCollection[account.value.address],
           upToDateAccount.isAvailable {
            account = upToDateAccount
        }
    }
}

extension BidaliDappDetailScreen {
    private func cancelPayment() {
        let script = "window.bidaliProvider.paymentCancelled();"
        webView.evaluateJavaScript(script)
    }

    private func confirmPayment() {
        let script = "window.bidaliProvider.paymentSent();"
        webView.evaluateJavaScript(script)
    }
}

extension BidaliDappDetailScreen {
    private func makeBalances(_ account: AccountHandle) -> BidaliBalances {
        switch api!.network {
        case .testnet:
            return makeBalancesForTestnet(account)
        case .mainnet, .localnet:
            return makeBalancesForMainnet(account)
        }
    }

    private func makeBalancesForTestnet(_ account: AccountHandle) -> BidaliBalances {
        let network = api!.network
        let aRawAccount = account.value

        let algo = aRawAccount.algo.decimalAmount
        let usdc = aRawAccount.usdc(network)?.decimalAmount
        return [
            BidaliPaymentCurrencyProtocol.algo.getRawValue(in: network): algo.stringValue,
            BidaliPaymentCurrencyProtocol.usdc.getRawValue(in: network): usdc?.stringValue
        ]
    }

    private func makeBalancesForMainnet(_ account: AccountHandle) -> BidaliBalances {
        let network = api!.network
        let aRawAccount = account.value

        let algo = aRawAccount.algo.decimalAmount
        let usdc = aRawAccount.usdc(network)?.decimalAmount
        let usdt = aRawAccount.usdt(network)?.decimalAmount
        return [
            BidaliPaymentCurrencyProtocol.algo.getRawValue(in: network): algo.stringValue,
            BidaliPaymentCurrencyProtocol.usdc.getRawValue(in: network): usdc?.stringValue,
            BidaliPaymentCurrencyProtocol.usdt.getRawValue(in: network): usdt?.stringValue
        ]
    }
}

extension BidaliDappDetailScreen {
    private func updateBalancesIfNeeded(old: AccountHandle, new: AccountHandle) {
        if shouldUpdateBalances(old: old, new: new) {
            updateBalance(new)
        }
    }

    private func shouldUpdateBalances(old: AccountHandle, new: AccountHandle) -> Bool {
        if isAlgoBalanceChanged(old: old, new: new) {
            return true
        }

        if isUSDCBalanceChanged(old: old, new: new) {
            return true
        }

        if isUSDtBalanceChanged(old: old, new: new) {
            return true
        }

        return false
    }

    private func isAlgoBalanceChanged(old: AccountHandle, new: AccountHandle) -> Bool {
        let oldAlgo = old.value.algo
        let newAlgo = new.value.algo
        return oldAlgo.decimalAmount != newAlgo.decimalAmount
    }

    private func isUSDCBalanceChanged(old: AccountHandle, new: AccountHandle) -> Bool {
        let network = api!.network
        let oldUSDC = old.value.usdc(network)
        let newUSDC = new.value.usdc(network)
        return oldUSDC?.decimalAmount != newUSDC?.decimalAmount
    }

    private func isUSDtBalanceChanged(old: AccountHandle, new: AccountHandle) -> Bool {
        let network = api!.network
        let oldUSDt = old.value.usdt(network)
        let newUSDt = new.value.usdt(network)
        return oldUSDt?.decimalAmount != newUSDt?.decimalAmount
    }

    private func updateBalance(_ account: AccountHandle) {
        let balances = makeBalances(account)

        guard let balancesJSONString = try? balances.encodedString() else { return }

        let script = "window.bidaliProvider.balances = \(balancesJSONString)"
        webView.evaluateJavaScript(script)
    }
}

extension BidaliDappDetailScreen {
    private func presentGenericErrorBanner() {
        bannerController?.presentErrorBanner(
            title: "title-error".localized,
            message: "title-generic-error".localized
        )
    }
}

enum BidaliDappDetailScriptMessage:
    String,
    InAppBrowserScriptMessage {
    case paymentRequest
    case openURLRequest
}

private extension Account {
    func asset(
        for currencyProtocol: BidaliPaymentCurrencyProtocol,
        network: ALGAPI.Network
    ) -> Asset? {
        switch currencyProtocol {
        case .algo: return algo
        case .usdc: return usdc(network)
        case .usdt: return usdt(network)
        default: return nil
        }
    }
}

private typealias BidaliBalances = [String: String?]
extension BidaliBalances: JSONModel  {}
