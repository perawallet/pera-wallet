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
//  TransactionFilterViewModel.swift

import UIKit
import SwiftDate

class TransactionFilterViewModel {
    func configure(_ cell: TransactionFilterOptionCell, with filterOption: TransactionFilterViewController.FilterOption, isSelected: Bool) {
        switch filterOption {
        case .allTime:
            configureAllTime(cell)
        case .today:
            configureToday(cell)
        case .yesterday:
            configureYesterday(cell)
        case .lastWeek:
            configureLastWeek(cell)
        case .lastMonth:
            configureLastMonth(cell)
        case let .customRange(from, to):
            configureCustomRange(cell, from: from, to: to)
        }
        
        if isSelected {
            cell.contextView.setSelected()
        } else {
            cell.contextView.setDeselected()
        }
    }
}

extension TransactionFilterViewModel {
    private func configureAllTime(_ cell: TransactionFilterOptionCell) {
        cell.contextView.setDateImage(img("icon-calendar-all"))
        cell.contextView.setTitle("transaction-filter-option-all".localized)
        cell.contextView.removeDateLabel()
    }
    
    private func configureToday(_ cell: TransactionFilterOptionCell) {
        let todaysDate = Date()
        cell.contextView.setDateImage(img("icon-calendar-all"))
        cell.contextView.setTitle("transaction-filter-option-today".localized)
        cell.contextView.setDate(todaysDate.toFormat("MMM dd"))
        cell.contextView.setDayText(todaysDate.toFormat("dd"))
    }

    private func configureYesterday(_ cell: TransactionFilterOptionCell) {
        let todaysDate = Date()
        cell.contextView.setDateImage(img("icon-calendar-yesterday"))
        cell.contextView.setTitle("transaction-filter-option-yesterday".localized)
        cell.contextView.setDate(todaysDate.dateAt(.yesterday).toFormat("MMM dd"))
    }
    
    private func configureLastWeek(_ cell: TransactionFilterOptionCell) {
        let todaysDate = Date()
        cell.contextView.setDateImage(img("icon-calendar-week"))
        cell.contextView.setTitle("transaction-filter-option-week".localized)
        let prevOfLastWeek = todaysDate.dateAt(.prevWeek)
        let endOfLastWeek = prevOfLastWeek.dateAt(.endOfWeek)
        
        if prevOfLastWeek.month == endOfLastWeek.month {
            cell.contextView.setDate("\(prevOfLastWeek.toFormat("MMM dd"))-\(endOfLastWeek.day)")
        } else {
            cell.contextView.setDate("\(prevOfLastWeek.toFormat("MMM dd"))-\(endOfLastWeek.toFormat("MMM dd"))")
        }
    }
    
    private func configureLastMonth(_ cell: TransactionFilterOptionCell) {
        let todaysDate = Date()
        cell.contextView.setDateImage(img("icon-calendar-all"))
        cell.contextView.setTitle("transaction-filter-option-month".localized)
        let prevOfLastMonth = todaysDate.dateAt(.prevMonth)
        let endOfLastMonth = prevOfLastMonth.dateAt(.endOfMonth)
        cell.contextView.setDate("\(prevOfLastMonth.toFormat("MMM dd"))-\(endOfLastMonth.day)")
        cell.contextView.setDayText("\(endOfLastMonth.day)")
    }
    
    private func configureCustomRange(_ cell: TransactionFilterOptionCell, from: Date?, to: Date?) {
        cell.contextView.setDateImage(img("icon-calendar-custom"))
        cell.contextView.setTitle("transaction-filter-option-custom".localized)
        
        if let from = from,
            let to = to {
            if from.year == to.year {
                cell.contextView.setDate("\(from.toFormat("MMM dd"))-\(to.toFormat("MMM dd"))")
            } else {
                cell.contextView.setDate("\(from.toFormat("MMM dd, yyyy"))-\(to.toFormat("MMM dd, yyyy"))")
            }
        } else {
            cell.contextView.removeDateLabel()
        }
    }
}
