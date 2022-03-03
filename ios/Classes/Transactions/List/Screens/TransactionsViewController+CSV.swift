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
//   TransactionsViewController+CSV.swift

import UIKit
import MacaroonUIKit

extension TransactionsViewController: CSVExportable {
    func fetchAllTransactionsForCSV() {
        loadingController?.startLoadingWithMessage("title-loading".localized)

        fetchAllTransactions(
            between: dataController.getTransactionFilterDates(),
            nextToken: nil
        )
    }

    private func fetchAllTransactions(
        between dates: (Date?, Date?),
        nextToken token: String?
    ) {
        var assetId: String?
        if let id = draft.compoundAsset?.id {
            assetId = String(id)
        }

        let draft = TransactionFetchDraft(account: draft.accountHandle.value, dates: dates, nextToken: token, assetId: assetId, limit: nil)

        api?.fetchTransactions(draft) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case .failure:
                self.loadingController?.stopLoading()
                self.csvTransactions.removeAll()
            case let .success(transactions):
                self.csvTransactions.append(contentsOf: transactions.transactions)

                if transactions.nextToken == nil {
                    self.shareCSVFile()
                    self.csvTransactions.removeAll()
                    return
                }

                self.fetchAllTransactions(between: dates, nextToken: transactions.nextToken)
            }
        }
    }

    private func shareCSVFile() {
        let keys: [String] = [
            "wallet-connect-asset-name-title".localized,
            "title-asset-id".localized,
            "transaction-detail-amount".localized,
            "transaction-detail-reward".localized,
            "transaction-detail-close-amount".localized,
            "transaction-download-close-to".localized,
            "transaction-download-to".localized,
            "transaction-download-from".localized,
            "transaction-detail-fee".localized,
            "transaction-detail-round".localized,
            "transaction-detail-date".localized,
            "title-id".localized,
            "transaction-detail-note".localized,
        ]
        let config = CSVConfig(fileName: formCSVFileName(), keys: NSOrderedSet(array: keys))

        if let fileUrl = exportCSV(from: createCSVData(from: csvTransactions), with: config) {
            loadingController?.stopLoading()

            let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = { _, _, _, _ in
                try? FileManager.default.removeItem(at: fileUrl)
            }
            present(activityViewController, animated: true)
        } else {
            loadingController?.stopLoading()
        }
    }

    private func formCSVFileName() -> String {
        var fileName = ""

        switch draft.type {
        case .all:
            fileName = "\(accountHandle.value.name ?? "")_transactions"
        case .asset:
            guard let id = compoundAsset?.id else {
                return ""
            }

            fileName = "\(accountHandle.value.name ?? "")_\(id)"
        case .algos:
            fileName = "\(accountHandle.value.name ?? "")_algos"
        }

        let dates = dataController.getTransactionFilterDates()
        if let fromDate = dates.from,
           let toDate = dates.to {
            if filterOption == .today {
                fileName += "-" + fromDate.toFormat("MM-dd-yyyy")
            } else {
                fileName += "-" + fromDate.toFormat("MM-dd-yyyy") + "_" + toDate.toFormat("MM-dd-yyyy")
            }
        }
        return "\(fileName).csv"
    }

    private func createCSVData(from transactions: [Transaction]) -> [[String: Any]] {
        var csvData = [[String: Any]]()
        for transaction in transactions {
            var transactionData: [String: Any] = [
                "transaction-detail-amount".localized: getFormattedAmount(transaction.getAmount(), for: transaction),
                "transaction-detail-reward".localized: transaction.getRewards(for: accountHandle.value.address)?.toAlgos ?? " ",
                "transaction-detail-close-amount".localized: getFormattedAmount(transaction.getCloseAmount(), for: transaction),
                "transaction-download-close-to".localized: transaction.getCloseAddress() ?? " ",
                "transaction-download-to".localized: transaction.getReceiver() ?? " ",
                "transaction-download-from".localized: transaction.sender ?? " ",
                "transaction-detail-fee".localized: transaction.fee?.toAlgos.toAlgosStringForLabel ?? " ",
                "transaction-detail-round".localized: transaction.lastRound ?? " ",
                "transaction-detail-date".localized: transaction.date?.toFormat("MMMM dd, yyyy - HH:mm:ss") ?? " ",
                "title-id".localized: transaction.id ?? " ",
                "transaction-detail-note".localized: transaction.noteRepresentation() ?? " "
            ]

            if let assetID = transaction.assetTransfer?.assetId {
                if let name = sharedDataController.assetDetailCollection[assetID]?.name {
                    transactionData["wallet-connect-asset-name-title".localized] = name
                }

                transactionData["title-asset-id".localized] = "\(assetID)"
            } else {
                transactionData["wallet-connect-asset-name-title".localized] = "Algo"
            }

            csvData.append(transactionData)
        }
        return csvData
    }

    private func getFormattedAmount(_ amount: UInt64?, for transaction: Transaction) -> String {
        switch draft.type {
        case .algos:
            return amount?.toAlgos.toAlgosStringForLabel ?? " "
        case .asset:
            guard let assetDetail = compoundAsset?.detail else {
                return amount?.assetAmount(fromFraction: 0).toFractionStringForLabel(fraction: 0) ?? " "
            }

            return amount?.assetAmount(fromFraction: assetDetail.decimals).toFractionStringForLabel(fraction: assetDetail.decimals) ?? " "
        case .all:
            if let assetID = transaction.assetTransfer?.assetId {
                if let decimal = sharedDataController.assetDetailCollection[assetID]?.decimals {
                    return amount?.assetAmount(fromFraction: decimal).toFractionStringForLabel(fraction: decimal) ?? " "
                }
            }

            return amount?.toAlgos.toAlgosStringForLabel ?? " "
        }
    }
}
