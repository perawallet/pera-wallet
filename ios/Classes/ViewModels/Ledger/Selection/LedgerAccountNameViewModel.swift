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
//  LedgerAccountNameViewModel.swift

import UIKit

class LedgerAccountNameViewModel {
    
    private(set) var selectionImage: UIImage?
    private(set) var accountNameViewModel: AccountNameViewModel
    
    init(account: Account, isMultiSelect: Bool, isSelected: Bool) {
        accountNameViewModel = AccountNameViewModel(account: account)
        setSelectionImage(isMultiSelect: isMultiSelect, isSelected: isSelected)
    }
    
    private func setSelectionImage(isMultiSelect: Bool, isSelected: Bool) {
        if isMultiSelect {
            selectionImage = isSelected ? img("icon-checkbox-selected") : img("icon-checkbox-unselected")
        } else {
            selectionImage = isSelected ? img("settings-node-active") : img("settings-node-inactive")
        }
    }
}
