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
//   WCTransactionActionableInformationViewModel.swift

import Foundation

final class WCTransactionActionableInformationViewModel {
    private(set) var title: String?
    private(set) var detail: String?
    private(set) var isSeparatorHidden: Bool = false

    init(information: ActionableInformation, isLastElement: Bool) {
        setTitle(from: information)
        setDetail(from: information)
        setIsSeparatorHidden(from: isLastElement)
    }

    private func setTitle(from information: ActionableInformation) {
        switch information {
        case .rawTransaction:
            title = "wallet-connect-transaction-title-raw".localized
        case .peraExplorer:
            title = "wallet-connect-transaction-title-explorer".localized
        case .assetUrl:
            title = "wallet-connect-transaction-title-asset-url".localized
        case .assetMetadata:
            title = "wallet-connect-transaction-title-metadata".localized
        }
    }

    private func setDetail(from information: ActionableInformation) {
        switch information {
        case .rawTransaction:
            detail = "wallet-connect-transaction-detail-raw".localized
        case .peraExplorer:
            detail = "wallet-connect-transaction-detail-explorer".localized
        case .assetUrl:
            detail = "wallet-connect-transaction-detail-asset-url".localized
        case .assetMetadata:
            detail = "wallet-connect-transaction-detail-metadata".localized
        }
    }

    private func setIsSeparatorHidden(from isLastElement: Bool) {
        isSeparatorHidden = isLastElement
    }
}

extension WCTransactionActionableInformationViewModel {
    enum ActionableInformation {
        case rawTransaction
        case peraExplorer
        case assetUrl
        case assetMetadata
    }
}
