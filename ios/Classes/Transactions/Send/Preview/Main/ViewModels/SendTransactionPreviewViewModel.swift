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
    private(set) var noteView: TransactionActionInformationViewModel?
    private(set) var lockedNoteView: TransactionTextInformationViewModel?

    init(
        _ model: TransactionSendDraft,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        if let algoTransactionSendDraft = model as? AlgosTransactionSendDraft {
            bindAlgoTransactionPreview(
                algoTransactionSendDraft,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
        } else if let assetTransactionSendDraft = model as? AssetTransactionSendDraft {
            bindAssetTransactionPreview(
                assetTransactionSendDraft,
                currency: currency,
                currencyFormatter: currencyFormatter
            )
        }
    }

    private func bindAlgoTransactionPreview(
        _ draft: AlgosTransactionSendDraft,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard
            let amount = draft.amount,
            let currencyValue = currency.fiatValue
        else {
            amountViewMode = nil
            balanceViewMode = nil
            return
        }

        do {
            let rawCurrency = try currencyValue.unwrap()

            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amountInCurrency = try exchanger.exchangeAlgo(amount: amount)
            let totalAmount = draft.from.algo.amount.toAlgos
            let totalAmountInCurrency = try exchanger.exchangeAlgo(amount: totalAmount)

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = rawCurrency

            let amountTextInCurrency = currencyFormatter.format(amountInCurrency)
            amountViewMode = .normal(
                amount: amount,
                isAlgos: true,
                fraction: algosFraction,
                currency: amountTextInCurrency
            )

            let totalAmountTextInCurrency = currencyFormatter.format(totalAmountInCurrency)
            balanceViewMode = .normal(
                amount: totalAmount,
                isAlgos: true,
                fraction: algosFraction,
                currency: totalAmountTextInCurrency
            )
        } catch {
            amountViewMode = nil
            balanceViewMode = nil
        }

        setUserView(for: draft)
        setOpponentView(for: draft)
        setFee(for: draft)
        setNote(for: draft)
    }

    private func bindAssetTransactionPreview(
        _ draft: AssetTransactionSendDraft,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        guard
            let amount = draft.amount,
            let asset = draft.asset,
            let currencyValue = currency.primaryValue
        else {
            amountViewMode = nil
            balanceViewMode = nil
            return
        }

        do {
            let rawCurrency = try currencyValue.unwrap()
            let assetFraction = asset.decimals
            let assetSymbol = asset.naming.name

            let exchanger = CurrencyExchanger(currency: rawCurrency)
            let amountInCurrency = try exchanger.exchange(
                asset,
                amount: amount
            )
            let totalAmountInCurrency = try exchanger.exchange(asset)

            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = rawCurrency

            let amountTextInCurrency = currencyFormatter.format(amountInCurrency)
            amountViewMode = .normal(
                amount: amount,
                isAlgos: false,
                fraction: assetFraction,
                assetSymbol: assetSymbol,
                currency: amountTextInCurrency
            )

            let totalAmountTextInCurrency = currencyFormatter.format(totalAmountInCurrency)
            balanceViewMode = .normal(
                amount: asset.decimalAmount,
                isAlgos: false,
                fraction: assetFraction,
                assetSymbol: assetSymbol,
                currency: totalAmountTextInCurrency
            )
        } catch {
            amountViewMode = nil
            balanceViewMode = nil
        }

        setUserView(for: draft)
        setOpponentView(for: draft)
        setFee(for: draft)
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
        } else if let nameService = draft.toNameService {
            opponentView = TitledTransactionAccountNameViewModel(
                title: title,
                nameService: nameService
            )
        } else if let toAccount = draft.toAccount {
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
        let isLocked = draft.lockedNote != nil
        let editNote = draft.lockedNote ?? draft.note
        
        if isLocked {
            lockedNoteView = TransactionTextInformationViewModel(
                title: "transaction-detail-note".localized,
                detail: editNote
            )
            
            return
        }
        
        noteView = TransactionActionInformationViewModel(
            description: editNote
        )
    }
}
