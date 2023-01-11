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

//   WCSessionAccountStatusViewModel.swift

import MacaroonUIKit

struct WCSessionAccountStatusViewModel: ViewModel {
    private(set) var accountStatus: TextProvider?
    
    init(account: Account) {
        bindAccountStatus(account)
    }
}

extension WCSessionAccountStatusViewModel {
    private mutating func bindAccountStatus(_ account: Account) {
        let displayName = account.name?.truncatingPrefix(40) ?? account.address.shortAddressDisplay
        
        let fullText = "wallet-connect-session-connected-with-account"
            .localized(params: displayName)
        
        accountStatus = fullText.footnoteMedium(
            alignment: .left
        )
    }
}
