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
//   WCTransactionRequestBottomViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WCSingleTransactionRequestBottomViewModel {
    private(set) var senderAddress: String?
    private(set) var networkFee: String?
    private(set) var warningMessage: String?
    private(set) var assetIcon: UIImage?
    private(set) var balance: String?

    init(transaction: WCTransaction, account: Account?, asset: Asset?) {
        let fee = transaction.transactionDetail?.fee ?? 0
        let warningCount = transaction.transactionDetail?.warningCount ?? 0
        networkFee = "\(fee.toAlgos.toAlgosStringForLabel ?? "")"
        senderAddress = transaction.signerAccount?.name ?? transaction.signerAccount?.address
        warningMessage = warningCount > 0 ? "node-settings-warning-title".localized: nil
        assetIcon = account?.image ?? account?.accountTypeImage()

        if let asset = asset as? StandardAsset {
            balance = "\(asset.amountWithFraction) \(asset.unitNameRepresentation)"
        } else {
            guard transaction.transactionDetail?.currentAssetId == nil,
                  let amount = account?.amount.toAlgos.toAlgosStringForLabel else {
                      return
            }

            balance = "\(amount)"
        }
    }
}
