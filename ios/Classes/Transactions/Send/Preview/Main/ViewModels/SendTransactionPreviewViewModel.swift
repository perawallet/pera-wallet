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
//   SendTransactionPreviewViewModel.swift


import Foundation
import UIKit
import MacaroonUIKit

final class SendTransactionPreviewViewModel: ViewModel {
    private(set) var amountViewMode: TransactionAmountView.Mode?
    private(set) var userView: TitledTransactionAccountNameViewModel?
    private(set) var opponentView: TitledTransactionAccountNameViewModel?
    private(set) var feeViewMode: TransactionAmountView.Mode?
    private(set) var balanceViewMode: TransactionAmountView.Mode?
    private(set) var noteViewDetail: String?

    init(_ model: TransactionSendDraft, currency: Currency?) {
        if let algoTransactionSendDraft = model as? AlgosTransactionSendDraft {
            bindAlgoTransactionPreview(algoTransactionSendDraft, with: currency)
        } else if let assetTransactionSendDraft = model as? AssetTransactionSendDraft {
            bindAssetTransactionPreview(assetTransactionSendDraft, with: currency)
        }
    }

    private func bindAlgoTransactionPreview(_ draft: AlgosTransactionSendDraft, with currency: Currency?) {
        guard let amount = draft.amount else {
            return
        }
        
        if let algoCurrency = currency as? AlgoCurrency {
            bindAlgoTransactionPreview(draft, with: algoCurrency.currency)
            return
        }

        let currencyString: String?

        if let currency = currency,
              let currencyPriceValue = currency.priceValue {
            let currencyValue = amount * currencyPriceValue
            currencyString = currencyValue.toCurrencyStringForLabel(with: currency.symbol)
        } else {
            currencyString = nil
        }

        amountViewMode = .normal(amount: amount, isAlgos: true, fraction: algosFraction, currency: currencyString)

        setUserView(for: draft)
        setOpponentView(for: draft)
        setFee(for: draft)

        let balance = draft.from.amount.toAlgos
        let balanceCurrencyString: String?

        if let currency = currency,
              let currencyPriceValue = currency.priceValue {
            let balanceCurrencyValue = balance * currencyPriceValue
            balanceCurrencyString = balanceCurrencyValue.toCurrencyStringForLabel(with: currency.symbol)
        } else {
            balanceCurrencyString = nil
        }

        balanceViewMode = .normal(amount: balance, isAlgos: true, fraction: algosFraction, currency: balanceCurrencyString)

        setNote(for: draft)
    }

    private func bindAssetTransactionPreview(_ draft: AssetTransactionSendDraft, with currency: Currency?) {
        guard let amount = draft.amount,
              let asset = draft.asset else {
            return
        }

        let currencyString: String?

        if let asset = asset as? StandardAsset,
           let assetUSDValue = asset.usdValue,
           let currency = currency,
           let currencyUSDValue = currency.usdValue {
            let currencyValue = assetUSDValue * amount * currencyUSDValue
            currencyString = currencyValue.toCurrencyStringForLabel(with: currency.symbol)
        } else {
            currencyString = nil
        }
        
        amountViewMode = .normal(
            amount: amount,
            isAlgos: false,
            fraction: algosFraction,
            assetSymbol: asset.presentation.name,
            currency: currencyString
        )

        setUserView(for: draft)
        setOpponentView(for: draft)
        setFee(for: draft)

        let balance = asset.amountWithFraction
        let balanceCurrencyString: String?

        if let asset = asset as? StandardAsset,
           let assetUSDValue = asset.usdValue,
           let currency = currency,
           let currencyUSDValue = currency.usdValue {
            let balanceCurrencyValue = assetUSDValue * balance * currencyUSDValue
            balanceCurrencyString = balanceCurrencyValue.toCurrencyStringForLabel(with: currency.symbol)
        } else {
            balanceCurrencyString = nil
        }

        balanceViewMode = .normal(
            amount: balance,
            isAlgos: false,
            fraction: algosFraction,
            assetSymbol: asset.presentation.name,
            currency: balanceCurrencyString
        )

        setNote(for: draft)
    }

    private func setUserView(
        for draft: TransactionSendDraft
    ) {
        userView = TitledTransactionAccountNameViewModel(
            title: "title-account".localized,
            account: draft.from,
            hasImage: true
        )
    }


    private func setOpponentView(
        for draft: TransactionSendDraft
    ) {
        let title = "transaction-detail-to".localized

        if let contact = draft.toContact {
            opponentView = TitledTransactionAccountNameViewModel(
                title: title,
                contact: contact,
                hasImage: true
            )
        } else {
            guard let toAccount = draft.toAccount else {
                return
            }

            opponentView = TitledTransactionAccountNameViewModel(
                title: title,
                account: toAccount,
                hasImage: toAccount.isCreated
            )
        }
    }

    private func setFee(
        for draft: TransactionSendDraft
    ) {
        if let fee = draft.fee {
            feeViewMode = .normal(amount: fee.toAlgos, isAlgos: true, fraction: algosFraction)
        }
    }

    private func setNote(
        for draft: TransactionSendDraft
    ) {
        if let note = draft.note {
            noteViewDetail = note
        }
    }
}
