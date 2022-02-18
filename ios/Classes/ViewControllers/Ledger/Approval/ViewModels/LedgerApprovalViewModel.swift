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
//   LedgerApprovalViewModel.swift

import MacaroonUIKit

final class LedgerApprovalViewModel {
    private(set) var title: String?
    private(set) var description: String?

    init(mode: LedgerApprovalViewController.Mode, deviceName: String) {
        bindTitle(mode)
        bindDescription(mode: mode, deviceName: deviceName)
    }
}

extension LedgerApprovalViewModel {
    private func bindTitle(_ mode: LedgerApprovalViewController.Mode) {
        switch mode {
        case .approve:
            title = "ledger-approval-title".localized
        case .connection:
            title = "ledger-approval-connection-title".localized
        }
    }

    private func bindDescription(mode: LedgerApprovalViewController.Mode, deviceName: String) {
        switch mode {
        case .approve:
            description = "ledger-approval-message".localized(deviceName)
        case .connection:
            description = "ledger-approval-connection-message".localized
        }
    }
}
