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
//  LedgerAccountViewModel.swift

import UIKit

class LedgerAccountViewModel {
    
    private(set) var subviews: [UIView] = []
    
    private let isMultiSelect: Bool
    let isSelected: Bool
    
    init(account: Account, isMultiSelect: Bool, isSelected: Bool) {
        self.isMultiSelect = isMultiSelect
        self.isSelected = isSelected
        setSubviews(from: account)
    }
    
    private func setSubviews(from account: Account) {
        addLedgerAccountNameView(with: account)
        addAlgoView(with: account)
        addLedgerAssetCountViewIfNeeded(with: account)
    }
    
    private func addLedgerAccountNameView(with account: Account) {
        let ledgerAccountNameView = LedgerAccountNameView()
        ledgerAccountNameView.bind(LedgerAccountNameViewModel(account: account, isMultiSelect: isMultiSelect, isSelected: isSelected))
        subviews.append(ledgerAccountNameView)
    }
    
    private func addAlgoView(with account: Account) {
        let algoView = AlgoAssetView()
        setAlgoAmount(from: account, in: algoView)
        
        if account.assets.isNilOrEmpty {
            algoView.setSeparatorHidden(true)
        }
        
        subviews.append(algoView)
    }
    
    private func addLedgerAssetCountViewIfNeeded(with account: Account) {
        if !account.assets.isNilOrEmpty {
            let ledgerAssetCountView = LedgerAccountAssetCountView()
            ledgerAssetCountView.bind(LedgerAccountAssetCountViewModel(account: account))
            subviews.append(ledgerAssetCountView)
            return
        }
    }
    
    private func setAlgoAmount(from account: Account, in view: AlgoAssetView) {
        view.bind(AlgoAssetViewModel(account: account))
    }
}
