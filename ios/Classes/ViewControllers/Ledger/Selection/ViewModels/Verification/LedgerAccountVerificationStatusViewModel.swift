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
//   LedgerAccountVerificationStatusViewModel.swift

import UIKit
import MacaroonUIKit

final class LedgerAccountVerificationStatusViewModel: ViewModel {
    private(set) var address: String?
    private let status: LedgerVerificationStatus

    var isWaitingForVerification: Bool {
        status == .awaiting
    }

    var isStatusImageHidden: Bool {
        status == .awaiting
    }
    
    var statusImage: Image? {
        switch status {
        case .pending:
            return "icon-clock-gray"
        case .verified:
            return "icon-check"
        case .unverified:
            return "icon-warning-red"
        case .awaiting:
            return nil
        }
    }

    var statusText: String {
        switch status {
        case .awaiting:
            return "ledger-account-verification-status-awaiting".localized
        case .pending:
            return "ledger-account-verification-status-pending".localized
        case .verified:
            return "ledger-account-verification-status-verified".localized
        case .unverified:
            return "ledger-account-verification-status-not-verified".localized
        }
    }
    
    var statusColor: Color {
        switch status {
        case .awaiting:
            return Colors.Helpers.negative
        case .pending:
            return Colors.Text.gray
        case .verified:
            return Colors.Link.primary
        case .unverified:
            return Colors.Helpers.negative
        }
    }

    var borderColor: Color {
        status == .awaiting ? Colors.Helpers.negative : UIColor.clear
    }

    init(account: Account, status: LedgerVerificationStatus) {
        self.status = status

        bindAddress(account)
    }
}

extension LedgerAccountVerificationStatusViewModel {
    private func bindAddress(_ account: Account) {
        address = getVerificationAddress(of: account)
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
