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
//   NoContentWithActionViewTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol NoContentViewWithActionTheme: ResultViewTheme {
    var contentHorizontalPaddings: LayoutHorizontalPaddings { get }
    var contentVerticalPaddings: LayoutVerticalPaddings { get }
    var actionContentEdgeInsets: LayoutPaddings { get }
    var actionCornerRadius: LayoutMetric { get }
    var primaryActionTopMargin: LayoutMetric { get }
    var primaryAction: ButtonStyle { get }
    var secondaryActionTopMargin: LayoutMetric { get }
    var secondaryAction: ButtonStyle { get }
    var actionAlignment: NoContentWithActionView.ActionViewAlignment { get }
}
