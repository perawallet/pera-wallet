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
//   TitledTransactionAccountNameViewModel.swift

import Foundation

class TitledTransactionAccountNameViewModel {
    private(set) var title: String?
    private(set) var accountNameViewModel: AccountNameViewModel?
    private(set) var isSeparatorHidden = false

    init(title: String, account: Account, isLastElement: Bool = false, hasImage: Bool = true) {
        setTitle(from: title)
        setAccountNameViewModel(from: account, and: hasImage)
        setIsSeparatorHidden(from: isLastElement)
    }

    private func setTitle(from title: String) {
        self.title = title
    }

    private func setAccountNameViewModel(from account: Account, and hasImage: Bool) {
        accountNameViewModel = AccountNameViewModel(account: account, hasImage: hasImage)
    }

    private func setIsSeparatorHidden(from isLastElement: Bool) {
        isSeparatorHidden = isLastElement
    }
}
