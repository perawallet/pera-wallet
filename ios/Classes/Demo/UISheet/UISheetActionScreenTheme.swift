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

//   UISheetActionScreenTheme.swift

import Foundation
import MacaroonUIKit
import UIKit

protocol UISheetActionScreenTheme:
    StyleSheet,
    LayoutSheet {
    var background: ViewStyle { get }
    var contextEdgeInsets: LayoutPaddings { get }
    var image: ImageStyle { get }
    var imageLayoutOffset: LayoutOffset { get }
    var title: TextStyle { get }
    var spacingBetweenTitleAndBody: LayoutMetric { get }
    var body: TextStyle { get }
    var spacingBetweenBodyAndInfo: LayoutMetric { get }
    var infoIcon: ImageStyle { get }
    var spacingBetweeenInfoIconAndInfoMessage: LayoutMetric { get }
    var infoMessage: TextStyle { get }
    var actionSpacing: LayoutMetric { get }
    var actionsEdgeInsets: LayoutPaddings { get }
    var actionContentEdgeInsets: LayoutPaddings { get }

    func getActionStyle(
        _ style: UISheetAction.Style,
        title: String
    ) -> ButtonStyle
}

extension UISheetActionScreenTheme {
    func getActionStyle(
          _ style: UISheetAction.Style,
          title: String
      ) -> ButtonStyle {
          switch style {
          case .default:
              return [
                  .title(title),
                  .font(Typography.bodyMedium()),
                  .titleColor([ .normal(Colors.Button.Primary.text) ]),
                  .backgroundImage([
                      .normal("components/buttons/primary/bg"),
                      .highlighted("components/buttons/primary/bg-highlighted"),
                  ])
              ]
          case .cancel:
              return [
                  .title(title),
                  .font(Typography.bodyMedium()),
                  .titleColor([ .normal(Colors.Button.Secondary.text) ]),
                  .backgroundImage([
                      .normal("components/buttons/secondary/bg"),
                      .highlighted("components/buttons/secondary/bg-highlighted"),
                  ])
              ]
          }
      }
}

struct UISheetActionScreenCommonTheme:
    UISheetActionScreenTheme {
    var background: ViewStyle
    var contextEdgeInsets: LayoutPaddings
    var image: ImageStyle
    var imageLayoutOffset: LayoutOffset
    var title: TextStyle
    var spacingBetweenTitleAndBody: LayoutMetric
    var body: TextStyle
    var spacingBetweenBodyAndInfo: LayoutMetric
    var infoIcon: ImageStyle
    var spacingBetweeenInfoIconAndInfoMessage: LayoutMetric
    var infoMessage: TextStyle
    var actionSpacing: LayoutMetric
    var actionsEdgeInsets: LayoutPaddings
    var actionContentEdgeInsets: LayoutPaddings

    init(
        _ family: LayoutFamily
    ) {
        self.background = [
            .backgroundColor(Colors.Defaults.background)
        ]
        self.contextEdgeInsets = (36, 24, 24, 24)
        self.image = []
        self.imageLayoutOffset = (0, 0)
        self.title = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyLargeMedium())
        ]
        self.spacingBetweenTitleAndBody = 16
        self.body = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.main),
            .font(Typography.bodyRegular())
        ]
        self.spacingBetweenBodyAndInfo = 28
        self.infoIcon = [
            .image("icon-red-warning".templateImage),
            .tintColor(Colors.Helpers.negative)
        ]
        self.spacingBetweeenInfoIconAndInfoMessage = 8
        self.infoMessage = [
            .textOverflow(FittingText()),
            .textColor(Colors.Helpers.negative),
            .font(Typography.footnoteMedium())
        ]
        self.actionSpacing = 16
        self.actionsEdgeInsets = (8, 24, 16, 24)
        self.actionContentEdgeInsets = (16, 24, 16, 24)
    }
}
