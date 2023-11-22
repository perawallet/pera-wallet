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

//   WCSessionNetworkRequestedPermissionViewModel.swift

import Foundation
import MacaroonUIKit

struct WCSessionNetworkRequestedPermissionViewModel: SecondaryListItemViewModel {
    private(set) var title: TextProvider?
    private(set) var accessory: SecondaryListItemValueViewModel?

    init(_ chains: [ALGAPI.Network]) {
        bindTitle()
        bindAccessory(chains)
    }
}

extension WCSessionNetworkRequestedPermissionViewModel {
    private mutating func bindTitle() {
        title =
            "wc-session-connection-network"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindAccessory(_ chains: [ALGAPI.Network]) {
        accessory = WCSessionNetworkRequestedPermissionValueViewModel(chains)
    }
}

fileprivate struct WCSessionNetworkRequestedPermissionValueViewModel: SecondaryListItemValueViewModel {
    private(set) var icon: ImageStyle?
    private(set) var title: TextProvider?

    init(_ chains: [ALGAPI.Network]) {
        bindTitle(chains)
    }
}

extension WCSessionNetworkRequestedPermissionValueViewModel {
    private mutating func bindTitle(_ chains: [ALGAPI.Network]) {
        var chainAccessories: [NSAttributedString] = []

        if chains.contains(.mainnet) {
            let accessory = getMainnetAccessory()
            chainAccessories.append(accessory)
        }

        if chains.contains(.testnet) {
            let accessory = getTestnetAccessory()
            chainAccessories.append(accessory)
        }

        let separator = "   "
        title = chainAccessories.compound(separator)
    }

    private func getMainnetAccessory() -> NSAttributedString {
        var attributes = Typography.captionBoldAttributes(
            alignment: .right,
            lineBreakMode: .byTruncatingTail
        )
        attributes.insert(.textColor(Colors.Helpers.positive))

        return "• MAINNET".attributed(attributes)
    }

    private func getTestnetAccessory() -> NSAttributedString {
        var attributes = Typography.captionBoldAttributes(
            alignment: .right,
            lineBreakMode: .byTruncatingTail
        )
        attributes.insert(.textColor(Colors.Other.Global.yellow600))

        return "• TESTNET".attributed(attributes)
    }
}
