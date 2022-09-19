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
//   PendingAssetPreviewViewModel.swift

import MacaroonUIKit
import UIKit

/// <todo> Use new list item structure
struct PendingAssetPreviewViewModel:
    ViewModel,
    Hashable {
    private(set) var id: AssetID
    private(set) var assetPrimaryTitle: String?
    private(set) var assetPrimaryTitleColor: Color?
    private(set) var secondaryImage: UIImage?
    private(set) var assetSecondaryTitle: String?
    private(set) var assetStatus: String?

    init(update: OptInBlockchainUpdate) {
        self.id = update.assetID

        bindAssetPrimaryTitle(update: update)
        bindAssetPrimaryTitleColor(update: update)
        bindSecondaryImage(update: update)
        bindAssetSecondaryTitle(update: update)
        bindAssetStatus(update: update)
    }

    init(update: OptOutBlockchainUpdate) {
        self.id = update.assetID

        bindAssetPrimaryTitle(update: update)
        bindAssetPrimaryTitleColor(update: update)
        bindSecondaryImage(update: update)
        bindAssetSecondaryTitle(update: update)
        bindAssetStatus(update: update)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(assetPrimaryTitle)
        hasher.combine(assetSecondaryTitle)
        hasher.combine(assetStatus)
    }

    static func == (
        lhs: PendingAssetPreviewViewModel,
        rhs: PendingAssetPreviewViewModel
    ) -> Bool {
        return
            lhs.id == rhs.id &&
            lhs.assetPrimaryTitle == rhs.assetPrimaryTitle &&
            lhs.assetSecondaryTitle == rhs.assetSecondaryTitle &&
            lhs.assetStatus == rhs.assetStatus
    }
}

extension PendingAssetPreviewViewModel {
    mutating func bindAssetPrimaryTitle(update: OptInBlockchainUpdate) {
        bindAssetPrimaryTitle(title: update.assetName)
    }

    mutating func bindAssetPrimaryTitleColor(update: OptInBlockchainUpdate) {
        bindAssetPrimaryTitleColor(verificationTier: update.assetVerificationTier)
    }

    mutating func bindSecondaryImage(update: OptInBlockchainUpdate) {
        bindSecondaryImage(verificationTier: update.assetVerificationTier)
    }

    mutating func bindAssetSecondaryTitle(update: OptInBlockchainUpdate) {
        bindAssetSecondaryTitle(title: update.assetUnitName)
    }

    mutating func bindAssetStatus(update: OptInBlockchainUpdate) {
        bindAssetStatus(status: "asset-add-confirmation-title".localized)
    }
}

extension PendingAssetPreviewViewModel {
    mutating func bindAssetPrimaryTitle(update: OptOutBlockchainUpdate) {
        bindAssetPrimaryTitle(title: update.assetName)
    }

    mutating func bindAssetPrimaryTitleColor(update: OptOutBlockchainUpdate) {
        bindAssetPrimaryTitleColor(verificationTier: update.assetVerificationTier)
    }

    mutating func bindSecondaryImage(update: OptOutBlockchainUpdate) {
        bindSecondaryImage(verificationTier: update.assetVerificationTier)
    }

    mutating func bindAssetSecondaryTitle(update: OptOutBlockchainUpdate) {
        bindAssetSecondaryTitle(title: update.assetUnitName)
    }

    mutating func bindAssetStatus(update: OptOutBlockchainUpdate) {
        bindAssetStatus(status: "asset-removing-status".localized)
    }
}

extension PendingAssetPreviewViewModel {
    mutating func bindAssetPrimaryTitle(title: String?) {
        self.assetPrimaryTitle = title.unwrapNonEmptyString() ?? "title-unknown".localized
    }

    mutating func bindAssetPrimaryTitleColor(verificationTier: AssetVerificationTier) {
        let isSuspicious = verificationTier.isSuspicious
        assetPrimaryTitleColor = isSuspicious ? Colors.Helpers.negative : Colors.Text.main
    }

    mutating func bindSecondaryImage(verificationTier: AssetVerificationTier) {
        switch verificationTier {
        case .trusted: self.secondaryImage = "icon-trusted".uiImage
        case .verified: self.secondaryImage = "icon-verified".uiImage
        case .unverified: self.secondaryImage = nil
        case .suspicious: self.secondaryImage = "icon-suspicious".uiImage
        }
    }

    mutating func bindAssetSecondaryTitle(title: String?) {
        self.assetSecondaryTitle = title
    }

    mutating func bindAssetStatus(status: String?) {
        self.assetStatus = status
    }
}
