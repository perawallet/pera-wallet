// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   OptInAssetListLoadingCell.swift

import Foundation
import MacaroonUIKit
import UIKit

final class OptInAssetListLoadingCell: CollectionCell<OptInAssetListLoadingView> {
    static let theme = OptInAssetListLoadingViewTheme()

    override func getContextView() -> OptInAssetListLoadingView {
        return OptInAssetListLoadingView(Self.theme)
    }
}

extension OptInAssetListLoadingCell {
    static func calculatePreferredSize(
        for theme: OptInAssetListLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return ContextView.calculatePreferredSize(
            for: theme,
            fittingIn: size
        )
    }
}

extension OptInAssetListLoadingCell {
    func startAnimating() {
        contextView.startAnimating()
    }

    func stopAnimating() {
        contextView.stopAnimating()
    }
}
