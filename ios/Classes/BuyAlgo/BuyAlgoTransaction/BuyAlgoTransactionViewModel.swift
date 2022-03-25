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

//   BuyAlgoTransactionViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct BuyAlgoTransactionViewModel: ViewModel {
    private(set) var image: Image?
    private(set) var title: EditText?
    private(set) var description: EditText?
    private(set) var accountName: EditText?
    private(set) var accountIcon: Image?
    
    init(
        status: BuyAlgoParams.TransactionStatus,
        account: Account
    ) {
        bindImage(status)
        bindTitle(status)
        bindDescription(status)
        bindAccountName(account)
        bindAccountIcon(account)
    }
}

/// <todo>
/// Refactor image, title and description when the design gets an update.
extension BuyAlgoTransactionViewModel {
    private mutating func bindImage(_ type: BuyAlgoParams.TransactionStatus) {
        switch type {
        case .completed:
            image = "icon-moonpay-transaction-completed"
        case .pending, .waitingAuthorization, .waitingPayment:
            image = "icon-moonpay-transaction-pending"
        case .failed:
            image = "icon-moonpay-transaction-failed"
        }
    }
    
    private mutating func bindTitle(_ type: BuyAlgoParams.TransactionStatus) {
        let font = Fonts.DMSans.medium.make(32).uiFont
        let lineHeightMultiplier = 0.96
        let titleString: String
        
        switch type {
        case .completed:
            titleString = "moonpay-transaction-completed-title"
        case .pending:
            titleString = "moonpay-transaction-pending-title"
        case .failed:
            titleString = "moonpay-transaction-failed-title"
        case .waitingAuthorization:
            titleString = "moonpay-transaction-waitingAuthorization-title"
        case .waitingPayment:
            titleString = "moonpay-transaction-waitingPayment-title"
            
        }
        
        title = .attributedString(
            titleString
                .localized
                .attributed(
                    [
                        .font(font),
                        .lineHeightMultiplier(lineHeightMultiplier, font),
                        .paragraph([
                            .textAlignment(.left),
                            .lineHeightMultiple(lineHeightMultiplier)
                        ]),
                    ]
                )
        )
    }
    
    private mutating func bindDescription(_ type: BuyAlgoParams.TransactionStatus) {
        let font = Fonts.DMSans.regular.make(15).uiFont
        let lineHeightMultiplier = 1.23
        let descriptionString: String
        
        switch type {
        case .completed:
            descriptionString = "moonpay-transaction-completed-description"
        case .pending:
            descriptionString = "moonpay-transaction-pending-description"
        case .failed:
            descriptionString = "moonpay-transaction-failed-description"
        case .waitingAuthorization:
            descriptionString = "moonpay-transaction-waitingAuthorization-description"
        case .waitingPayment:
            descriptionString = "moonpay-transaction-waitingPayment-description"
        }

        description = .attributedString(
            descriptionString
                .localized
                .attributed(
                    [
                        .font(font),
                        .lineHeightMultiplier(lineHeightMultiplier, font),
                        .paragraph([
                            .textAlignment(.left),
                            .lineBreakMode(.byWordWrapping),
                            .lineHeightMultiple(lineHeightMultiplier)
                        ]),
                    ]
                )
        )
    }
    
    private mutating func bindAccountName(_ account: Account) {
        let name = account.name ?? account.address.shortAddressDisplay()
        
        let font = Fonts.DMSans.regular.make(15).uiFont
        let lineHeightMultiplier = 1.23
        
        accountName = .attributedString(name
            .attributed(
                [
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .textAlignment(.left),
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ]),
                ]
            )
        )
    }
    
    private mutating func bindAccountIcon(_ account: Account) {
        accountIcon = account.type.image(for: .getRandomImage(for: account.type))
    }
}
