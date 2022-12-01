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

//   HomeAccountCell.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomeAccountCell:
    CollectionCell<AccountListItemView>,
    ViewModelBindable {
    override class var contextPaddings: LayoutPaddings {
        return (14, 24, 14, 24)
    }

    static let theme = AccountListItemViewTheme()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        contextView.customize(Self.theme)

        let separator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .bottom((80, 24))
        )
        separatorStyle = .single(separator)
    }
}
