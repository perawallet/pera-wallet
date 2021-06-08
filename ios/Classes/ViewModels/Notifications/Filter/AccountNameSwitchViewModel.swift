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
//  AccountNameSwitchViewModel.swift

import Foundation

class AccountNameSwitchViewModel {

    private(set) var accountNameViewModel: AccountNameViewModel
    private(set) var isSelected: Bool = true
    private(set) var isSeparatorHidden: Bool = false

    init(account: Account, isLastIndex: Bool) {
        accountNameViewModel = AccountNameViewModel(account: account)
        setIsSelected(from: account)
        setIsSeparatorHidden(isLastIndex: isLastIndex)
    }

    private func setIsSelected(from account: Account) {
        isSelected = account.receivesNotification
    }

    private func setIsSeparatorHidden(isLastIndex: Bool) {
        isSeparatorHidden = isLastIndex
    }
}
