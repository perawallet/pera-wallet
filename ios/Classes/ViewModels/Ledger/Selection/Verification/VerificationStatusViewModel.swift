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
//   VerificationStatusViewModel.swift

import UIKit

class VerificationStatusViewModel {

    private(set) var isWaitingForVerification = true
    private(set) var isStatusImageHidden = true
    private(set) var statusImage: UIImage?
    private(set) var statusText: String?
    private(set) var statusColor: UIColor?

    init(status: LedgerVerificationStatus) {
        setIsWaitingForVerification(from: status)
        setIsStatusImageHidden(from: status)
        setStatusImage(from: status)
        setStatusText(from: status)
        setStatusColor(from: status)
    }

    private func setIsWaitingForVerification(from status: LedgerVerificationStatus) {
        isWaitingForVerification = status == .awaiting
    }

    private func setIsStatusImageHidden(from status: LedgerVerificationStatus) {
        isStatusImageHidden = status == .awaiting
    }

    private func setStatusImage(from status: LedgerVerificationStatus) {
        switch status {
        case .pending:
            statusImage = img("icon-clock-gray")
        case .verified:
            statusImage = img("icon-check")
        case .unverified:
            statusImage = img("icon-warning-red")
        case .awaiting:
            statusImage = nil
        }
    }

    private func setStatusText(from status: LedgerVerificationStatus) {
        switch status {
        case .awaiting:
            statusText = "ledger-account-verification-status-awaiting".localized
        case .pending:
            statusText = "ledger-account-verification-status-pending".localized
        case .verified:
            statusText = "ledger-account-verification-status-verified".localized
        case .unverified:
            statusText = "ledger-account-verification-status-not-verified".localized
        }
    }

    private func setStatusColor(from status: LedgerVerificationStatus) {
        switch status {
        case .awaiting:
            statusColor = Colors.Main.yellow700
        case .pending:
            statusColor = Colors.Text.secondary
        case .verified:
            statusColor = Colors.General.success
        case .unverified:
            statusColor = Colors.General.error
        }
    }
}
