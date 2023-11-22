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
//   WCSessionItemViewTheme.swift

import MacaroonUIKit
import UIKit

struct WCSessionItemViewTheme: LayoutSheet, StyleSheet {
    let image: URLImageViewStyleLayoutSheet
    let imageSize: LayoutSize
    let imageBorder: Border
    let imageCorner: Corner
    let name: TextStyle
    let nameHorizontalPadding: LayoutMetric
    let spacingBetweenWCv1BadgeAndName: LayoutMetric
    let wcV1Badge: TextStyle
    let wcV1BadgeContentEdgeInsets: LayoutPaddings
    let wcV1BadgeCorner: Corner
    let descriptionTopPadding: LayoutMetric
    let description: TextStyle
    let spacingBetweeenDescriptionAndStatus: LayoutMetric
    let pingingStatus: TextStyle
    let connectedStatus: TextStyle
    let disconnectedStatus: TextStyle
    let statusCorner: Corner
    let statusContentEdgeInsets: LayoutPaddings
    let spacingBetweenContentAndDisclosureIcon: LayoutMetric
    let disclosureIconTopPadding: LayoutMetric
    let disclosureIcon: ImageStyle

    init(_ family: LayoutFamily) {
        self.image = URLImageViewNoStyleLayoutSheet()
        self.imageSize = (40, 40)
        self.imageBorder = Border(
            color: Colors.Layer.grayLighter.uiColor,
            width: 1
        )
        self.imageCorner = Corner(radius: imageSize.h / 2)
        self.name = [
            .textOverflow(SingleLineText()),
            .textColor(Colors.Text.main)
        ]
        self.nameHorizontalPadding = 16
        self.spacingBetweenWCv1BadgeAndName = 6
        self.wcV1Badge = [
            .textColor(Colors.Text.gray),
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .backgroundColor(Colors.Layer.grayLighter)
        ]
        self.wcV1BadgeContentEdgeInsets =  (2, 8, 2, 8)
        self.wcV1BadgeCorner = Corner(radius: 13)
        self.description = [
            .textOverflow(FittingText()),
            .textColor(Colors.Text.grayLighter),
        ]
        self.descriptionTopPadding = 4
        self.spacingBetweeenDescriptionAndStatus = 8
        self.pingingStatus = Self.getPingingStatus()
        self.connectedStatus = Self.getConnectedStatus()
        self.disconnectedStatus = Self.getDisconnectedStatus()
        self.statusCorner = Corner(radius: 13)
        self.statusContentEdgeInsets = (2, 8, 2, 8)
        self.spacingBetweenContentAndDisclosureIcon = 16
        self.disclosureIconTopPadding = 8
        self.disclosureIcon = [
            .image("icon-list-arrow"),
            .contentMode(.scaleAspectFit)
        ]
    }

    subscript (status: WCSessionStatus) -> TextStyle {
        switch status {
        case .active: return connectedStatus
        case .failed: return disconnectedStatus
        default: return pingingStatus
        }
    }
}

extension WCSessionItemViewTheme {
    private static func getPingingStatus() -> TextStyle {
        let text =
            "tite-pinging"
                .localized
                .footnoteMedium(
                    alignment: .center,
                    lineBreakMode: .byTruncatingTail
                )
        return [
            .text(text),
            .textColor(Colors.Text.gray),
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .backgroundColor(Colors.Layer.grayLighter.uiColor)
        ]
    }

    private static func getConnectedStatus() -> TextStyle {
        let text =
            "wallet-connect-session-connected"
                .localized
                .footnoteMedium(
                    alignment: .center,
                    lineBreakMode: .byTruncatingTail
                )
        return [
            .text(text),
            .textColor(Colors.Helpers.positive),
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .backgroundColor(Colors.Helpers.positiveLighter.uiColor.withAlphaComponent(0.5))
        ]
    }

    private static func getDisconnectedStatus() -> TextStyle {
        let text =
            "wallet-connect-session-disconnected"
                .localized
                .footnoteMedium(
                    alignment: .center,
                    lineBreakMode: .byTruncatingTail
                )
        return [
            .text(text),
            .textColor(Colors.Helpers.negative),
            .textAlignment(.center),
            .textOverflow(SingleLineText()),
            .backgroundColor(Colors.Helpers.negativeLighter.uiColor.withAlphaComponent(0.5))
        ]
    }
}
