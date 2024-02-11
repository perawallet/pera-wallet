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

//   ErrorScreenViewModel.swift

import MacaroonUIKit
import UIKit

protocol ErrorScreenViewModel {
    var title: TextProvider? { get }
    var detail: TextProvider? { get }
    var primaryAction: TextProvider? { get }
    var secondaryAction: TextProvider? { get }
}

extension ErrorScreenViewModel {
    func getTitle(
        from quote: SwapQuote
    ) -> String? {
        guard let assetIn = quote.assetIn,
              let assetOut = quote.assetOut else {
            return nil
        }

        let formatter = SwapAssetValueFormatter()

        let assetInDisplayName = formatter.getAssetDisplayName(assetIn)
        let assetOutDisplayName = formatter.getAssetDisplayName(assetOut)
        let swapAssets = "\(assetInDisplayName) / \(assetOutDisplayName)"
        return "swap-error-failed-title".localized(params: swapAssets)
    }
}
