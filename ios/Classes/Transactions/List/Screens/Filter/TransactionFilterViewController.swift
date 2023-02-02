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
//  TransactionFilterViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

final class TransactionFilterViewController: BaseViewController {
    weak var delegate: TransactionFilterViewControllerDelegate?
    
    private lazy var theme = Theme()
    private(set) lazy var transactionFilterView = TransactionFilterView()

    private var selectedOption: FilterOption
    private(set) var filterOptions = FilterOption.allCases
    
    init(filterOption: FilterOption, configuration: ViewControllerConfiguration) {
        self.selectedOption = filterOption
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        title = "filter".localized
        hidesCloseBarButtonItem = true
    }
    
    override func linkInteractors() {
        transactionFilterView.delegate = self
        transactionFilterView.setCollectionViewDelegate(self)
        transactionFilterView.setCollectionViewDataSource(self)
    }
    
    override func prepareLayout() {
        view.addSubview(transactionFilterView)
        transactionFilterView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension TransactionFilterViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return theme.calculateModalHeightAsBottomSheet(self)
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
        let cell = collectionView.dequeue(TransactionFilterOptionCell.self, at: indexPath)
        let selectedFilterOption = filterOptions[indexPath.item]

        cell.bindData(
            TransactionFilterOptionViewModel(
                selectedFilterOption,
                isSelected: selectedFilterOption == selectedOption
            )
        )

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
        return CGSize(theme.cellSize)
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
    enum FilterOption: Equatable, CaseIterable, Hashable {
        static let allCases: [TransactionFilterViewController.FilterOption] = {
            [.allTime, .today, .yesterday, .lastWeek, .lastMonth, .customRange(from: nil, to: nil)]
        }()

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

        func getDateRanges() -> (from: Date?, to: Date?) {
            switch self {
            case .allTime:
                return (nil, nil)
            case .today:
                return (Date().dateAt(.startOfDay), Date().dateAt(.endOfDay))
            case .yesterday:
                let yesterday = Date().dateAt(.yesterday)
                let endOfYesterday = yesterday.dateAt(.endOfDay)
                return (yesterday, endOfYesterday)
            case .lastWeek:
                let prevOfLastWeek = Date().dateAt(.prevWeek)
                let endOfLastWeek = prevOfLastWeek.dateAt(.endOfWeek)
                return (prevOfLastWeek, endOfLastWeek)
            case .lastMonth:
                let prevOfLastMonth = Date().dateAt(.prevMonth)
                let endOfLastMonth = prevOfLastMonth.dateAt(.endOfMonth)
                return (prevOfLastMonth, endOfLastMonth)
            case let .customRange(from, to):
                return (from, to)
            }
        }
    }
}

protocol TransactionFilterViewControllerDelegate: AnyObject {
    func transactionFilterViewController(
        _ transactionFilterViewController: TransactionFilterViewController,
        didSelect filterOption: TransactionFilterViewController.FilterOption
    )
}
