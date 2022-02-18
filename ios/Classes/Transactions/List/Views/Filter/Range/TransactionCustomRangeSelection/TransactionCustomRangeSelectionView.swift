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
//  TransactionCustomRangeSelectionView.swift

import UIKit
import MacaroonUIKit

final class TransactionCustomRangeSelectionView: View {
    private lazy var fromRangeSelectionView = RangeSelectionView()
    private lazy var toRangeSelectionView = RangeSelectionView()
    private lazy var datePickerView = UIDatePicker()
    
    var fromRangeSelectionHandler: ((RangeSelectionView) -> Void)?
    var toRangeSelectionHandler: ((RangeSelectionView) -> Void)?
    var datePickerChangesHandler: ((UIDatePicker) -> Void)?

    func setListeners() {
        fromRangeSelectionView.addTarget(self, action: #selector(notifyDelegateToOpenPickerForFromDate), for: .touchUpInside)
        toRangeSelectionView.addTarget(self, action: #selector(notifyDelegateToOpenPickerForToDate), for: .touchUpInside)
        datePickerView.addTarget(self, action: #selector(notifyDelegateToUpdatePickerDate), for: .valueChanged)
    }

    func customize(_ theme: TransactionCustomRangeSelectionViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addFromRangeSelectionView(theme)
        addToRangeSelectionView(theme)
        addDatePickerView(theme)
    }

    func customizeAppearance(_ styleSheet: ViewStyle) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension TransactionCustomRangeSelectionView {
    @objc
    private func notifyDelegateToOpenPickerForFromDate() {
        fromRangeSelectionHandler?(fromRangeSelectionView)
    }
    
    @objc
    private func notifyDelegateToOpenPickerForToDate() {
        toRangeSelectionHandler?(toRangeSelectionView)
    }
    
    @objc
     private func notifyDelegateToUpdatePickerDate(datePickerView: UIDatePicker) {
        datePickerChangesHandler?(datePickerView)
     }
}

extension TransactionCustomRangeSelectionView {
    private func addFromRangeSelectionView(_ theme: TransactionCustomRangeSelectionViewTheme) {
        fromRangeSelectionView.bindData(RangeSelectionViewModel(range: .from))

        addSubview(fromRangeSelectionView)
        fromRangeSelectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }
    
    private func addToRangeSelectionView(_ theme: TransactionCustomRangeSelectionViewTheme) {
        toRangeSelectionView.bindData(RangeSelectionViewModel(range: .to))

        addSubview(toRangeSelectionView)
        toRangeSelectionView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().inset(theme.topInset)
            $0.leading.equalTo(fromRangeSelectionView.snp.trailing).offset(theme.horizontalInset)
            $0.width.height.equalTo(fromRangeSelectionView)
        }
    }
    
    private func addDatePickerView(_ theme: TransactionCustomRangeSelectionViewTheme) {
        datePickerView.datePickerMode = .date
        datePickerView.maximumDate = Date()

        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        }

        addSubview(datePickerView)
        datePickerView.snp.makeConstraints {
            $0.leading.centerX.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + theme.pickerBottomInset)
            $0.top.equalTo(fromRangeSelectionView.snp.bottom).offset(theme.pickerTopInset)
        }
    }
}

extension TransactionCustomRangeSelectionView: ViewModelBindable {
    func bindData(_ viewModel: TransactionCustomRangeSelectionViewModel?) {
        if let fromDateRangeSelectionViewModel = viewModel?.fromRangeSelectionViewModel {
            fromRangeSelectionView.bindData(fromDateRangeSelectionViewModel)
        }

        if let toDateRangeSelectionViewModel = viewModel?.toRangeSelectionViewModel {
            toRangeSelectionView.bindData(toDateRangeSelectionViewModel)
        }

        if let detePickerViewDate = viewModel?.datePickerViewDate {
            fromRangeSelectionView.setSelected(viewModel?.fromRangeSelectionViewIsSelected)
            toRangeSelectionView.setSelected(viewModel?.toRangeSelectionViewIsSelected)
            datePickerView.date = detePickerViewDate
        }
    }
}
