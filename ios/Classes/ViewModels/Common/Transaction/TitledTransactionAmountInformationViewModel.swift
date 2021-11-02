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
//   TitledTransactionAmountInformationViewModel.swift

import Foundation

class TitledTransactionAmountInformationViewModel {
    private(set) var title: String?
    private(set) var amountMode: TransactionAmountView.Mode?
    private(set) var isSeparatorHidden = false

    init(title: String, mode: AmountMode, isLastElement: Bool) {
        setTitle(from: title)
        setAmountMode(from: mode)
        setIsSeparatorHidden(from: isLastElement)
    }

    private func setTitle(from title: String) {
        self.title = title
    }

    private func setAmountMode(from mode: AmountMode) {
        switch mode {
        case let .fee(value):
            amountMode = .normal(amount: value.toAlgos)
        case let .balance(value, isAlgos, fraction):
            if isAlgos {
                amountMode = .normal(amount: value.toAlgos)
            } else {
                amountMode = .normal(amount: value.assetAmount(fromFraction: fraction ?? 0), isAlgos: false, fraction: fraction)
            }
        case let .amount(value, isAlgos, fraction):
            if isAlgos {
                amountMode = .normal(amount: value.toAlgos)
            } else {
                amountMode = .normal(amount: value.assetAmount(fromFraction: fraction ?? 0), isAlgos: false, fraction: fraction)
            }
        }
    }

    private func setIsSeparatorHidden(from isLastElement: Bool) {
        isSeparatorHidden = isLastElement
    }
}

extension TitledTransactionAmountInformationViewModel {
    enum AmountMode {
        case fee(value: UInt64)
        case balance(value: UInt64, isAlgos: Bool = true, fraction: Int? = nil)
        case amount(value: UInt64, isAlgos: Bool = true, fraction: Int? = nil)
    }
}
