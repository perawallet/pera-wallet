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

//   SwapQuickActionsGroupViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol SwapQuickActionsGroupViewModel: ViewModel {
    var actionItems: [SwapQuickActionItem] { get }
}

protocol SwapQuickActionItem {
    typealias Layout = MacaroonUIKit.Button.Layout
    typealias Style = ButtonStyle

    var layout: Layout { get }
    var style: Style { get }
    var contentEdgeInsets: UIEdgeInsets { get }
    var isEnabled: Bool { get }
}

extension Array: ViewModel where Element == any SwapQuickActionItem {}

extension Array: SwapQuickActionsGroupViewModel where Element == any SwapQuickActionItem {
    var actionItems: [SwapQuickActionItem] {
        return self
    }
}
