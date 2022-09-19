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
//   Shadows.swift

import UIKit
import MacaroonUIKit

enum Shadows {
    case primaryShadow

    func create() -> MacaroonUIKit.Shadow {
        switch self {
        case .primaryShadow:
            return PrimaryShadow().create()
        }
    }
}

extension Shadows {
    private struct PrimaryShadow {
        // <todo>: Make it 3 shadow
        func create() -> MacaroonUIKit.Shadow {
            return MacaroonUIKit.Shadow(
                color: UIColor.black,
                fillColor: Colors.Defaults.background.uiColor,
                opacity: 0.08,
                offset: (0, 2),
                radius: 4,
                cornerRadii: (4, 4),
                corners: .allCorners
            )
        }
    }
}
