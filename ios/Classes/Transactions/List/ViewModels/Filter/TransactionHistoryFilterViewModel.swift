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
//  TransactionHistoryFilterViewModel.swift

import UIKit
import MacaroonUIKit

struct TransactionHistoryFilterViewModel:
    PairedViewModel,
    Hashable {
    private(set) var hasBadge: Bool = false
    private(set) var title: String?

    init(_ filterOption: TransactionFilterViewController.FilterOption) {
        bindBadge(from: filterOption)
        bindTitle(from: filterOption)
    }
}

extension TransactionHistoryFilterViewModel {
    private mutating func bindBadge(from filterOption: TransactionFilterViewController.FilterOption) {
        switch filterOption {
        case .allTime:
            hasBadge = false
        case .today, .yesterday, .lastWeek, .lastMonth, .customRange:
            hasBadge = true
        }
    }

    private mutating func bindTitle(from filterOption: TransactionFilterViewController.FilterOption) {
        switch filterOption {
        case .allTime:
            title = "accounts-transactions-title".localized
        case .today:
            title = "transaction-filter-option-today".localized
        case .yesterday:
            title = "transaction-filter-option-yesterday".localized
        case .lastWeek:
            title = "transaction-filter-option-week".localized
        case .lastMonth:
            title = "transaction-filter-option-month".localized
        case let .customRange(from, to):
            if let from = from,
                let to = to {
                if from.year == to.year {
                    title = "\(from.toFormat("MMM dd"))-\(to.toFormat("MMM dd"))"
                } else {
                    title = "\(from.toFormat("MMM dd, yyyy"))-\(to.toFormat("MMM dd, yyyy"))"
                }
            }
        }
    }
}
