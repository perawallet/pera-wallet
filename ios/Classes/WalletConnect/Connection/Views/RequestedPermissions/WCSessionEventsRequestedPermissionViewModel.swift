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

//   WCSessionEventsRequestedPermissionViewModel.swift

import Foundation
import MacaroonUIKit

struct WCSessionEventsRequestedPermissionViewModel: SecondaryListItemViewModel {
    private(set) var title: TextProvider?
    private(set) var accessory: SecondaryListItemValueViewModel?

    init(_ events: Set<WCSessionSupportedEvent>) {
        bindTitle()
        bindAccessory(events)
    }
}

extension WCSessionEventsRequestedPermissionViewModel {
    private mutating func bindTitle() {
        title =
            "wc-session-connection-wc-events"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindAccessory(_ events: Set<WCSessionSupportedEvent>) {
        accessory = WCSessionEventsRequestedPermissionValueViewModel(events)
    }
}

fileprivate struct WCSessionEventsRequestedPermissionValueViewModel: SecondaryListItemValueViewModel {
    private(set) var icon: ImageStyle?
    private(set) var title: TextProvider?

    init(_ events: Set<WCSessionSupportedEvent>) {
        bindTitle(events)
    }
}

extension WCSessionEventsRequestedPermissionValueViewModel {
    private mutating func bindTitle(_ events: Set<WCSessionSupportedEvent>) {
        let aTitle: String = events.map(\.rawValue).sorted().joined(separator: ", ")
        title = aTitle.footnoteRegular(lineBreakMode: .byTruncatingTail)
    }
}
