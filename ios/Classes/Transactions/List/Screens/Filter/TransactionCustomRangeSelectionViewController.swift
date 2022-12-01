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
//  TransactionCustomRangeSelectionViewController.swift

import UIKit
import SwiftDate

final class TransactionCustomRangeSelectionViewController: BaseViewController {
    weak var delegate: TransactionCustomRangeSelectionViewControllerDelegate?

    private lazy var transactionCustomRangeSelectionView = TransactionCustomRangeSelectionView()
    
    private var isFromRangeSelectionSelected = true
    private var fromDate: Date
    private var toDate: Date
    
    init(fromDate: Date?, toDate: Date?, configuration: ViewControllerConfiguration) {
        self.fromDate = fromDate ?? Date().dateAt(.yesterday)
        self.toDate = toDate ?? Date()
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
       addBarButtons()
    }
    
    override func setListeners() {
        transactionCustomRangeSelectionView.setListeners()
        handleFromRangeSelectionActions()
        handleToRangeSelectionActions()
        handleDatePickerChangeActions()
    }

    override func bindData() {
        title = "transaction-filter-option-custom".localized

        transactionCustomRangeSelectionView.bindData(
            TransactionCustomRangeSelectionViewModel(
                fromRangeSelectionViewModel: RangeSelectionViewModel(date: fromDate),
                toRangeSelectionViewModel: RangeSelectionViewModel(date: toDate)
            )
        )

        transactionCustomRangeSelectionView.bindData(
            TransactionCustomRangeSelectionViewModel(.from, datePickerViewDate: fromDate)
        )
    }
    
    override func prepareLayout() {
        transactionCustomRangeSelectionView.customize(TransactionCustomRangeSelectionViewTheme())
        view.addSubview(transactionCustomRangeSelectionView)
        transactionCustomRangeSelectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension TransactionCustomRangeSelectionViewController {
    private func addBarButtons() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done(Colors.Link.primary.uiColor)) { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.transactionCustomRangeSelectionViewController(
                strongSelf,
                didSelect: (from: strongSelf.fromDate, to: strongSelf.toDate)
            )
            strongSelf.dismissScreen()
        }

        rightBarButtonItems = [doneBarButtonItem]
    }
}

extension TransactionCustomRangeSelectionViewController {
    private func handleFromRangeSelectionActions() {
        transactionCustomRangeSelectionView.fromRangeSelectionHandler = { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.isFromRangeSelectionSelected = true
            strongSelf.transactionCustomRangeSelectionView.bindData(
                TransactionCustomRangeSelectionViewModel(.from, datePickerViewDate: strongSelf.fromDate)
            )
        }
    }
    
    private func handleToRangeSelectionActions() {
        transactionCustomRangeSelectionView.toRangeSelectionHandler = { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.isFromRangeSelectionSelected = false
            strongSelf.transactionCustomRangeSelectionView.bindData(
                TransactionCustomRangeSelectionViewModel(.to, datePickerViewDate: strongSelf.toDate)
            )
        }
    }
    
    private func handleDatePickerChangeActions() {
        transactionCustomRangeSelectionView.datePickerChangesHandler = { [weak self] datePickerView in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.isFromRangeSelectionSelected {
                if datePickerView.date > strongSelf.toDate {
                    datePickerView.date = strongSelf.fromDate
                    return
                }
                
                strongSelf.fromDate = datePickerView.date
                strongSelf.transactionCustomRangeSelectionView.bindData(
                    TransactionCustomRangeSelectionViewModel(
                        fromDateRangeSelectionViewModel: RangeSelectionViewModel(date: strongSelf.fromDate)
                    )
                )
            } else {
                if datePickerView.date < strongSelf.fromDate {
                    datePickerView.date = strongSelf.toDate
                    return
                }
                
                strongSelf.toDate = datePickerView.date
                strongSelf.transactionCustomRangeSelectionView.bindData(
                    TransactionCustomRangeSelectionViewModel(
                        toDateRangeSelectionViewModel: RangeSelectionViewModel(date: strongSelf.toDate)
                    )
                )
            }
        }
    }
}

protocol TransactionCustomRangeSelectionViewControllerDelegate: AnyObject {
    func transactionCustomRangeSelectionViewController(
        _ transactionCustomRangeSelectionViewController: TransactionCustomRangeSelectionViewController,
        didSelect range: (from: Date, to: Date)
    )
}
