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
//  TransactionCustomRangeSelectionView.swift

import UIKit

class TransactionCustomRangeSelectionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var fromRangeSelectionView = RangeSelectionView()
    private lazy var toRangeSelectionView = RangeSelectionView()
    
    var fromRangeSelectionHandler: ((RangeSelectionView) -> Void)?
    var toRangeSelectionHandler: ((RangeSelectionView) -> Void)?
    var datePickerChangesHandler: ((UIDatePicker) -> Void)?
    
    private lazy var datePickerView: UIDatePicker = {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = .date
        if #available(iOS 13.4, *) {
            pickerView.preferredDatePickerStyle = .wheels
        }
        pickerView.maximumDate = Date()
        return pickerView
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
        fromRangeSelectionView.setTitle("transaction-detail-from".localized)
        fromRangeSelectionView.setImage(img("icon-calendar-custom-pick-from"))
        fromRangeSelectionView.setSelected(true)
        toRangeSelectionView.setTitle("transaction-detail-to".localized)
        toRangeSelectionView.setImage(img("icon-calendar-custom-pick-to"))
        toRangeSelectionView.setSelected(false)
    }
    
    override func setListeners() {
        fromRangeSelectionView.addTarget(self, action: #selector(notifyDelegateToOpenPickerForFromDate), for: .touchUpInside)
        toRangeSelectionView.addTarget(self, action: #selector(notifyDelegateToOpenPickerForToDate), for: .touchUpInside)
        datePickerView.addTarget(self, action: #selector(notifyDelegateToUpdatePickerDate(datePickerView:)), for: .valueChanged)
    }
    
    override func prepareLayout() {
        setupFromRangeSelectionViewLayout()
        setupToRangeSelectionViewLayout()
        setupDatePickerViewLayout()
    }
}

extension TransactionCustomRangeSelectionView {
    @objc
    private func notifyDelegateToOpenPickerForFromDate() {
        guard let fromRangeSelectionHandler = fromRangeSelectionHandler else {
            return
        }
        fromRangeSelectionHandler(fromRangeSelectionView)
    }
    
    @objc
    private func notifyDelegateToOpenPickerForToDate() {
        guard let toRangeSelectionHandler = toRangeSelectionHandler else {
            return
        }
        toRangeSelectionHandler(toRangeSelectionView)
    }
    
    @objc
     private func notifyDelegateToUpdatePickerDate(datePickerView: UIDatePicker) {
        guard let datePickerChangesHandler = datePickerChangesHandler else {
            return
        }
        datePickerChangesHandler(datePickerView)
     }
}

extension TransactionCustomRangeSelectionView {
    private func setupFromRangeSelectionViewLayout() {
        addSubview(fromRangeSelectionView)
        
        fromRangeSelectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupToRangeSelectionViewLayout() {
        addSubview(toRangeSelectionView)
        
        toRangeSelectionView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.equalTo(fromRangeSelectionView.snp.trailing).offset(layout.current.horizontalInset)
            make.width.height.equalTo(fromRangeSelectionView)
        }
    }
    
    private func setupDatePickerViewLayout() {
        addSubview(datePickerView)
        
        datePickerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + layout.current.pickerBottomInset)
            make.top.equalTo(fromRangeSelectionView.snp.bottom).offset(layout.current.pickerTopInset)
        }
    }
}

extension TransactionCustomRangeSelectionView {
    func setFromDate(_ date: String) {
        fromRangeSelectionView.setDate(date)
    }
    
    func setToDate(_ date: String) {
        toRangeSelectionView.setDate(date)
    }
    
    func setPickerDate(_ date: Date) {
        datePickerView.date = date
    }
    
    func setFromRangeSelectionViewSelected(_ isSelected: Bool) {
        fromRangeSelectionView.setSelected(isSelected)
    }
    
    func setToRangeSelectionViewSelected(_ isSelected: Bool) {
        toRangeSelectionView.setSelected(isSelected)
    }
}

extension TransactionCustomRangeSelectionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let topInset: CGFloat = 12.0
        let pickerTopInset: CGFloat = 20.0
        let pickerBottomInset: CGFloat = 16.0
    }
}
