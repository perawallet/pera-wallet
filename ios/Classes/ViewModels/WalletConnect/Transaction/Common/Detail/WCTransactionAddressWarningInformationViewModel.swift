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
//   WCTransactionAddressWarningInformationView.swift

import Foundation

class WCTransactionAddressWarningInformationViewModel {
    private(set) var title: String?
    private(set) var detail: String?
    private(set) var warningViewModel: WCTransactionWarningViewModel?
    private(set) var isSeparatorHidden = false

    init(address: String, warning: WCTransactionWarning, isLastElement: Bool) {
        setTitle(from: warning)
        setDetail(from: address)
        setWarningViewModel(from: warning)
        setIsSeparatorHidden(from: isLastElement)
    }

    private func setTitle(from warning: WCTransactionWarning) {
        switch warning {
        case .closeAlgos:
            title = "wallet-connect-transaction-warning-close-algos-title".localized
        case .closeAsset:
            title = "wallet-connect-transaction-warning-close-asset-title".localized
        case .rekeyed:
            title = "wallet-connect-transaction-warning-rekey-title".localized
        case .fee:
            break
        }
    }

    private func setDetail(from address: String) {
        detail = address
    }

    private func setWarningViewModel(from warning: WCTransactionWarning) {
        warningViewModel = WCTransactionWarningViewModel(warning: warning)
    }

    private func setIsSeparatorHidden(from isLastElement: Bool) {
        isSeparatorHidden = isLastElement
    }
}
