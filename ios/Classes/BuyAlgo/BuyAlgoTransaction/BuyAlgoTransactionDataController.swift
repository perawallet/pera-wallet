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

//   BuyAlgoTransactionDataController.swift

import Foundation

final class BuyAlgoTransactionDataController: NSObject {
    weak var delegate: BuyAlgoTransactionDataControllerDelegate?
    
    private let sharedDataController: SharedDataController
    private let accountAddress: String
    
    init(sharedDataController: SharedDataController, accountAddress: String) {
        self.sharedDataController = sharedDataController
        self.accountAddress = accountAddress
        super.init()
    }
    
    func loadData() {
        let account = sharedDataController.accountCollection.account(for: accountAddress) ??
            Account(address: accountAddress, type: .standard)
        
        delegate?.buyAlgoTransactionDataControllerDidLoad(self, account: account)
    }
}

protocol BuyAlgoTransactionDataControllerDelegate: AnyObject {
    func buyAlgoTransactionDataControllerDidLoad(
        _ dataController: BuyAlgoTransactionDataController,
        account: Account
    )
}
