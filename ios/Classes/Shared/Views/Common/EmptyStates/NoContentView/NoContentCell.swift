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
//   NoContentCell.swift

import Foundation
import MacaroonUIKit
import UIKit

final class NoContentCell:
    CollectionCell<NoContentView>,
    ViewModelBindable {
    static let theme = NoContentViewCommonTheme()

    override init(
        frame: CGRect
    ) {
        super.init(
            frame: frame
        )

        customize()
    }

    func customize() {
        contextView.customize(Self.theme)
    }
}

final class NoContentTopAlignedCell:
    CollectionCell<NoContentView>,
    ViewModelBindable {
    static let theme = NoContentViewTopAttachedTheme()

    override init(
        frame: CGRect
    ) {
        super.init(
            frame: frame
        )

        customize()
    }

    func customize() {
        contextView.customize(Self.theme)
    }
}

enum NoContentCellType {
    case topAligned
    case centered
}
