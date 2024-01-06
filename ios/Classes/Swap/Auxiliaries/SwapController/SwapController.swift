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

//   SwapController.swift

import Foundation
import MagpieCore
import MagpieExceptions
import MagpieHipo

protocol SwapController {
    typealias EventHandler = (SwapControllerEvent) -> Void
    typealias Error = HIPNetworkError<IndexerError>

    var userAsset: Asset { get set }
    var quote: SwapQuote? { get set }
    var poolAsset: Asset? { get set }
    var slippage: Decimal? { get set }
    var account: Account { get set }
    var swapType: SwapType { get }
    var providers: [SwapProvider] { get }
    var parsedTransactions: [ParsedSwapTransaction] { get }

    func signTransactions(_ transactions: [SwapTransactionGroup])
    func clearTransactions()
    func uploadTransactions()

    func disconnectFromLedger()
}

enum SwapControllerEvent {
    case didSignTransaction
    case didSignAllTransactions
    case didCompleteSwap
    case didFailTransaction(TxnID)
    case didFailNetwork(SwapController.Error)
    case didCancelTransaction
    case didFailSigning(error: SwapTransactionSigner.SignError)
    case didLedgerRequestUserApproval(ledger: String, transactionGroups: [SwapTransactionGroup])
    case didFinishTiming
    case didLedgerReset
    case didLedgerResetOnSuccess
    case didLedgerRejectSigning
}
