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
//   AccountHandle.swift


import Foundation
import MagpieCore
import MagpieHipo

struct AccountHandle: Hashable {
    var isAvailable: Bool {
        return status == .ready
    }
    
    let value: Account
    let status: Status
    
    init(
        localAccount: AccountInformation,
        status: Status
    ) {
        self.init(
            account: Account(localAccount: localAccount),
            status: status
        )
    }
    
    init(
        account: Account,
        status: Status
    ) {
        self.value = account
        self.status = status
    }
}

extension AccountHandle {
    enum Status: Hashable {
        case idle /// Local account.
        case inProgress /// Account is ready but not assets yet.
        case failed(HIPNetworkError<NoAPIModel>) /// Account or assets aren't ready.
        case ready /// Account and assets are ready.
    }
}
