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

//   AssetVerificationInfoViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AssetVerificationInfoViewModel: ViewModel {
    var assetVerification: AssetVerificationTierInfoBoxViewModel?
    var learnMore: ListItemButtonViewModel?

    init(
        _ verificationTier: AssetVerificationTier
    ) {
        bindAssetVerification(verificationTier)
        bindLearnMore()
    }
}

extension AssetVerificationInfoViewModel {
    private mutating func bindAssetVerification(
        _ verificationTier: AssetVerificationTier
    ) {
        assetVerification = AssetVerificationTierInfoBoxViewModel(
            verificationTier
        )
    }

    private mutating func bindLearnMore(
    ) {
        learnMore = AssetLearnMoreListItemButtonViewModel()
    }
}
