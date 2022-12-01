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

//   SwapAssetSelectionViewModel.swift

import Foundation
import MacaroonUIKit

protocol SwapAssetSelectionViewModel: ViewModel {
    var title: TextProvider?  { get }
    var verificationTier: Image?  { get }
    var accessory: Image? { get }
}

extension SwapAssetSelectionViewModel {
    func getVerificationTier(
        _ asset: Asset
    ) -> Image? {
        switch asset.verificationTier {
        case .trusted: return "icon-trusted"
        case .verified: return "icon-verified"
        case .unverified: return nil
        case .suspicious: return "icon-suspicious"
        }
    }
}
