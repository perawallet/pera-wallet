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
//   LedgerAccountVerificationStatusViewModel.swift

import UIKit

class LedgerAccountVerificationStatusViewModel {

    private(set) var address: String?
    private(set) var backgroundColor: UIColor?
    private(set) var borderColor: UIColor?
    private(set) var verificationStatusViewModel: VerificationStatusViewModel?

    init(account: Account, status: LedgerVerificationStatus) {
        setAddress(from: account)
        setBackgroundColor(from: status)
        setBorderColor(from: status)
        setVerificationStatusViewModel(from: status)
    }

    private func setAddress(from account: Account) {
        address = getVerificationAddress(of: account)
    }

    private func setBackgroundColor(from status: LedgerVerificationStatus) {
        switch status {
        case .awaiting:
            backgroundColor = Colors.Background.secondary
        case .pending:
            backgroundColor = .clear
        case .unverified:
            backgroundColor = Colors.General.error.withAlphaComponent(0.1)
        case .verified:
            backgroundColor = Colors.Background.secondary
        }
    }

    private func setBorderColor(from status: LedgerVerificationStatus) {
        if status == .awaiting {
            borderColor = Colors.Main.yellow700
        } else {
            borderColor = .clear
        }
    }

    private func setVerificationStatusViewModel(from status: LedgerVerificationStatus) {
        verificationStatusViewModel = VerificationStatusViewModel(status: status)
    }
}

extension LedgerAccountVerificationStatusViewModel {
    private func getVerificationAddress(of account: Account) -> String {
        if let authAddress = account.authAddress,
           let rekeyedLedgerDetail = account.rekeyDetail?[authAddress] {
            if let ledgerDetail = account.ledgerDetail,
                rekeyedLedgerDetail.id != ledgerDetail.id {
                return account.address
            } else {
                return authAddress
            }
        }

        return account.address
    }
}
