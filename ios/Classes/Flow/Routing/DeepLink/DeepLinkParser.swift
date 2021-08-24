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
//  DeepLinkParser.swift

import UIKit

struct DeepLinkParser {
    
    private let url: URL
    
    init(url: URL) {
        self.url = url
    }

    var wcSessionRequestText: String? {
        let initialAlgorandPrefix = "algorand-wc://"

        if !url.absoluteString.hasPrefix(initialAlgorandPrefix) {
            return nil
        }

        let uriQueryKey = "uri"

        guard let possibleWCRequestText = url.queryParameters?[uriQueryKey] else {
            return nil
        }

        if possibleWCRequestText.isWalletConnectConnection {
            return possibleWCRequestText
        }

        return nil
    }
    
    var expectedScreen: Screen? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let accountAddress = urlComponents.host,
            accountAddress.isValidatedAddress(),
            let qrText = url.buildQRText() else {
            return nil
        }
        
        switch qrText.mode {
        case .address:
            return .addContact(mode: .new(address: accountAddress, name: qrText.label))
        case .algosRequest:
            if let amount = qrText.amount {
                return .sendAlgosTransactionPreview(
                    account: nil,
                    receiver: .address(address: accountAddress, amount: "\(amount)"),
                    isSenderEditable: false,
                    qrText: qrText
                )
            }
        case .assetRequest:
            guard let assetId = qrText.asset,
                let userAccounts = UIApplication.shared.appConfiguration?.session.accounts else {
                return nil
            }
            
            var requestedAssetDetail: AssetDetail?
            
            for account in userAccounts {
                for assetDetail in account.assetDetails where assetDetail.id == assetId {
                    requestedAssetDetail = assetDetail
                }
            }
            
            guard let assetDetail = requestedAssetDetail else {
                let assetAlertDraft = AssetAlertDraft(
                    account: nil,
                    assetIndex: assetId,
                    assetDetail: nil,
                    title: "asset-support-title".localized,
                    detail: "asset-support-error".localized,
                    actionTitle: "title-ok".localized
                )
                
                return .assetSupport(assetAlertDraft: assetAlertDraft)
            }
                
            if let amount = qrText.amount {
                return .sendAssetTransactionPreview(
                    account: nil,
                    receiver: .address(address: accountAddress, amount: "\(amount)"),
                    assetDetail: assetDetail,
                    isSenderEditable: false,
                    isMaxTransaction: false,
                    qrText: qrText
                )
            }
        case .mnemonic:
            return nil
        }
        
        return nil
    }
}
