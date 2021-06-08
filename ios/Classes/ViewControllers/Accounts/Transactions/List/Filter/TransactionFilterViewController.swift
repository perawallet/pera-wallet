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
//  TransactionFilterViewController.swift

import UIKit

class TransactionFilterViewController: BaseViewController {
    
    weak var delegate: TransactionFilterViewControllerDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var transactionFilterView = TransactionFilterView()
    
    private let viewModel = TransactionFilterViewModel()
    private var selectedOption: FilterOption
    private var filterOptions: [FilterOption] = [.allTime, .today, .yesterday, .lastWeek, .lastMonth, .customRange(from: nil, to: nil)]
    
    init(filterOption: FilterOption, configuration: ViewControllerConfiguration) {
        self.selectedOption = filterOption
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
        setSecondaryBackgroundColor()
        title = "transaction-filter-title-sort".localized
    }
    
    override func linkInteractors() {
        transactionFilterView.delegate = self
        transactionFilterView.filterOptionsCollectionView.delegate = self
        transactionFilterView.filterOptionsCollectionView.dataSource = self
    }
    
    override func prepareLayout() {
        setupTransactionFilterViewLayout()
    }
}

extension TransactionFilterViewController {
    private func setupTransactionFilterViewLayout() {
        view.addSubview(transactionFilterView)
        
        transactionFilterView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension TransactionFilterViewController: TransactionFilterViewDelegate {
    func transactionFilterViewDidDismissView(_ transactionFilterView: TransactionFilterView) {
        delegate?.transactionFilterViewController(self, didSelect: selectedOption)
        dismissScreen()
    }
}

extension TransactionFilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TransactionFilterOptionCell.reusableIdentifier,
            for: indexPath
        ) as? TransactionFilterOptionCell else {
            fatalError("Index path is out of bounds")
        }
        
        let filterOption = filterOptions[indexPath.item]
        
        if selectedOption.isCustomRange() && filterOption == selectedOption {
            viewModel.configure(cell, with: selectedOption, isSelected: true)
        } else {
            viewModel.configure(cell, with: filterOption, isSelected: filterOption == selectedOption)
        }
        
        return cell
    }
}

extension TransactionFilterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFilterOption = filterOptions[indexPath.item]
        
        if selectedFilterOption.isCustomRange() {
            if selectedOption.isCustomRange() {
                switch selectedOption {
                case let .customRange(from, to):
                    openCustomRangeSelection(fromDate: from, toDate: to)
                default:
                    break
                }
            } else {
                openCustomRangeSelection(fromDate: nil, toDate: nil)
            }
        } else {
            self.selectedOption = selectedFilterOption
            delegate?.transactionFilterViewController(self, didSelect: selectedOption)
            dismissScreen()
        }
    }
    
    private func openCustomRangeSelection(fromDate: Date?, toDate: Date?) {
        let controller = open(
            .transactionFilterCustomRange(
                fromDate: fromDate,
                toDate: toDate
            ),
            by: .push
        ) as? TransactionCustomRangeSelectionViewController
        controller?.delegate = self
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return layout.current.cellSize
    }
}

extension TransactionFilterViewController: TransactionCustomRangeSelectionViewControllerDelegate {
    func transactionCustomRangeSelectionViewController(
        _ transactionCustomRangeSelectionViewController: TransactionCustomRangeSelectionViewController,
        didSelect range: (from: Date, to: Date)
    ) {
        selectedOption = .customRange(from: range.from, to: range.to)
        delegate?.transactionFilterViewController(self, didSelect: selectedOption)
        dismissScreen()
    }
}

extension TransactionFilterViewController {
    enum FilterOption: Equatable {
        case allTime
        case today
        case yesterday
        case lastWeek
        case lastMonth
        case customRange(from: Date?, to: Date?)
        
        static func == (lhs: FilterOption, rhs: FilterOption) -> Bool {
            switch (lhs, rhs) {
            case (.allTime, .allTime):
                return true
            case (.today, .today):
                return true
            case (.yesterday, .yesterday):
                return true
            case (.lastWeek, .lastWeek):
                return true
            case (.lastMonth, .lastMonth):
                return true
            case (.customRange, .customRange):
                return true
            default:
                return false
            }
        }
        
        func isCustomRange() -> Bool {
            return self == .customRange(from: nil, to: nil)
        }
    }
}

extension TransactionFilterViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellSize = CGSize(width: UIScreen.main.bounds.width, height: 52.0)
    }
}

protocol TransactionFilterViewControllerDelegate: class {
    func transactionFilterViewController(
        _ transactionFilterViewController: TransactionFilterViewController,
        didSelect filterOption: TransactionFilterViewController.FilterOption
    )
}
