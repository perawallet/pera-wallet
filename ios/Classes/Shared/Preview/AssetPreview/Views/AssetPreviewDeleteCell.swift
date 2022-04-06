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

//   AssetPreviewDeleteCell.swift

import UIKit
import MacaroonUIKit

final class AssetPreviewDeleteCell:
    CollectionCell<AssetPreviewDeleteView>,
    ViewModelBindable,
    UIInteractionObservable {
    static let theme: AssetPreviewDeleteViewTheme = {
        var theme = AssetPreviewDeleteViewTheme()
        theme.configureForAssetPreviewAddition()
        return theme
    }()
    
    override class var contextPaddings: LayoutPaddings {
        return (14, 0, 14, 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contextView.customize(Self.theme)
    }
}
