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

//   WCSessionAdvancedPermissionsHeader.swift

import Foundation
import UIKit
import MacaroonUIKit

final class WCSessionAdvancedPermissionsHeader:
    UICollectionViewListCell,
    UIInteractable {
    static let theme = WCSessionAdvancedPermissionsHeaderContentConfiguration.theme

    var uiInteractions: [WCSessionAdvancedPermissionsHeaderView.Event : MacaroonUIKit.UIInteraction] {
        let contentView = contentView as? WCSessionAdvancedPermissionsHeaderView
        return contentView?.uiInteractions ?? [:]
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        automaticallyUpdatesContentConfiguration = false
        automaticallyUpdatesBackgroundConfiguration = false

        accessories = [ makeDisclosureAccessory() ]
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func calculatePreferredSize(
        _ viewModel: WCSessionAdvancedPermissionsHeaderViewModel?,
        for theme: WCSessionAdvancedPermissionsHeaderViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return WCSessionAdvancedPermissionsHeaderView.calculatePreferredSize(
            viewModel,
            for: theme,
            fittingIn: size
        )
    }
}

extension WCSessionAdvancedPermissionsHeader {
    private func makeDisclosureAccessory() -> UICellAccessory {
        let accessoryOptions = UICellAccessory.OutlineDisclosureOptions(
            style: .header,
            tintColor: Colors.Text.grayLighter.uiColor
        )
        return .outlineDisclosure(options: accessoryOptions)
    }
}
