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
//   TransactionFilterOptionViewModel.swift

import MacaroonUIKit
import UIKit

final class TransactionFilterOptionViewModel: ViewModel {
    private(set) var title: String?
    private(set) var dateImage: UIImage?
    private(set) var dateImageText: String?
    private(set) var date: String?
    private(set) var isSelected: Bool?

    private lazy var todaysDate = Date()
    
    init(_ option: TransactionFilterViewController.FilterOption, isSelected: Bool) {
        bindTitle(option)
        bindDateImage(option)
        bindDate(option)
        bindDateImageText(option)
        self.isSelected = isSelected
    }
}

extension TransactionFilterOptionViewModel {
    private func bindTitle(_ option: TransactionFilterViewController.FilterOption) {
        switch option {
        case .allTime:
            title = "transaction-filter-option-all".localized
        case .today:
            title = "transaction-filter-option-today".localized
        case .yesterday:
            title = "transaction-filter-option-yesterday".localized
        case .lastWeek:
            title = "transaction-filter-option-week".localized
        case .lastMonth:
            title = "transaction-filter-option-month".localized
        case .customRange:
            title = "transaction-filter-option-custom".localized
        }
    }

    private func bindDateImage(_ option: TransactionFilterViewController.FilterOption) {
        switch option {
        case .allTime:
            dateImage = img("icon-calendar-all")
        case .today:
            dateImage = img("icon-calendar-all")
        case .yesterday:
            dateImage = img("icon-calendar-yesterday")
        case .lastWeek:
            dateImage = img("icon-calendar-week")
        case .lastMonth:
            dateImage = img("icon-calendar-all")
        case .customRange:
            dateImage = img("icon-calendar-custom")
        }
    }

    private func bindDate(_ option: TransactionFilterViewController.FilterOption) {
        switch option {
        case .allTime:
            date = nil
        case .today:
            date = todaysDate.toFormat("MMM dd")
        case .yesterday:
            date = todaysDate.dateAt(.yesterday).toFormat("MMM dd")
        case .lastWeek:
            let prevOfLastWeek = todaysDate.dateAt(.prevWeek)
            let endOfLastWeek = prevOfLastWeek.dateAt(.endOfWeek)

            if prevOfLastWeek.month == endOfLastWeek.month {
                date = "\(prevOfLastWeek.toFormat("MMM dd"))-\(endOfLastWeek.day)"
            } else {
                date = "\(prevOfLastWeek.toFormat("MMM dd"))-\(endOfLastWeek.toFormat("MMM dd"))"
            }
        case .lastMonth:
            let prevOfLastMonth = todaysDate.dateAt(.prevMonth)
            let endOfLastMonth = prevOfLastMonth.dateAt(.endOfMonth)
            date = "\(prevOfLastMonth.toFormat("MMM dd"))-\(endOfLastMonth.day)"
        case let .customRange(from, to):
            if let from = from,
                let to = to {
                if from.year == to.year {
                    date = "\(from.toFormat("MMM dd"))-\(to.toFormat("MMM dd"))"
                } else {
                    date = "\(from.toFormat("MMM dd, yyyy"))-\(to.toFormat("MMM dd, yyyy"))"
                }
            }
        }
    }

    private func bindDateImageText(_ option: TransactionFilterViewController.FilterOption) {
        switch option {
        case .today:
            dateImageText = todaysDate.toFormat("dd")
        case .lastMonth:
            let prevOfLastMonth = todaysDate.dateAt(.prevMonth)
            let endOfLastMonth = prevOfLastMonth.dateAt(.endOfMonth)
            dateImageText = "\(endOfLastMonth.day)"
        default:
            break
        }
    }
}
