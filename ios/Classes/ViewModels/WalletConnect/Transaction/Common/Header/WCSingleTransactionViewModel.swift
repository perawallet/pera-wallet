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
//   WCSingleTransactionViewModel.swift

import UIKit

class WCSingleTransactionViewModel {
    private(set) var transactionDappMessageViewModel: WCTransactionDappMessageViewModel?

    init(wcSession: WCSession, transaction: WCTransaction) {
        setTransactionDappMessageViewModel(from: wcSession, and: transaction)
    }

    private func setTransactionDappMessageViewModel(from wcSession: WCSession, and transaction: WCTransaction) {
        transactionDappMessageViewModel = WCTransactionDappMessageViewModel(
            session: wcSession,
            text: transaction.message,
            imageSize: CGSize(width: 44.0, height: 44.0)
        )
    }
}
