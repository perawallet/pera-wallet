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
//   TitledTransactionAccountNameViewModel.swift

import Foundation

class TitledTransactionAccountNameViewModel {
    private(set) var title: String?
    private(set) var accountNameViewModel: AccountNameViewModel?

    init(title: String, account: Account, hasImage: Bool = true) {
        setTitle(from: title)
        setAccountNameViewModel(from: account, and: hasImage)
    }

    init(title: String, contact: Contact, hasImage: Bool = true) {
        setTitle(from: title)
        setAccountNameViewModel(from: contact, and: hasImage)
    }

    init(title: String, nameService: NameService) {
        setTitle(from: title)
        setAccountNameViewModel(from: nameService)
    }

    private func setTitle(from title: String) {
        self.title = title
    }

    private func setAccountNameViewModel(from account: Account, and hasImage: Bool) {
        accountNameViewModel = AccountNameViewModel(account: account, hasImage: hasImage)
    }

    private func setAccountNameViewModel(from contact: Contact, and hasImage: Bool) {
        accountNameViewModel = AccountNameViewModel(contact: contact, hasImage: hasImage)
    }

    private func setAccountNameViewModel(from nameService: NameService) {
        accountNameViewModel = AccountNameViewModel(nameService: nameService)
    }
}
