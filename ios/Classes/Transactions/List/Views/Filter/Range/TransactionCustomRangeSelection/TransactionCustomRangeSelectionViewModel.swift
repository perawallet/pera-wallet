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
//   TransactionCustomRangeSelectionViewModel.swift

import MacaroonUIKit
import UIKit

final class TransactionCustomRangeSelectionViewModel: ViewModel {
    private(set) var fromRangeSelectionViewModel: RangeSelectionViewModel?
    private(set) var toRangeSelectionViewModel: RangeSelectionViewModel?
    private(set) var fromRangeSelectionViewIsSelected: Bool?
    private(set) var toRangeSelectionViewIsSelected: Bool?
    private(set) var datePickerViewDate: Date?

    init(
        fromRangeSelectionViewModel: RangeSelectionViewModel,
        toRangeSelectionViewModel: RangeSelectionViewModel
    ) {
        self.fromRangeSelectionViewModel = fromRangeSelectionViewModel
        self.toRangeSelectionViewModel = toRangeSelectionViewModel
    }

    init(fromDateRangeSelectionViewModel: RangeSelectionViewModel) {
        self.fromRangeSelectionViewModel = fromDateRangeSelectionViewModel
    }

    init(toDateRangeSelectionViewModel: RangeSelectionViewModel) {
        self.toRangeSelectionViewModel = toDateRangeSelectionViewModel
    }

    init(_ range: RangeSelectionViewModel.Range, datePickerViewDate: Date) {
        self.toRangeSelectionViewIsSelected = range == .to
        self.fromRangeSelectionViewIsSelected = range == .from
        self.datePickerViewDate = datePickerViewDate
    }
}
