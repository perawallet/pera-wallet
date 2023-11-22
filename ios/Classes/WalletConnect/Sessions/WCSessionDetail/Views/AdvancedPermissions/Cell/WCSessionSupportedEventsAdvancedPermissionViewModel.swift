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

//   WCSessionSupportedEventsAdvancedPermissionViewModel.swift

import Foundation
import MacaroonUIKit

struct WCSessionSupportedEventsAdvancedPermissionViewModel: PrimaryTitleViewModel {
    private(set) var primaryTitle: TextProvider?
    private(set) var primaryTitleAccessory: Image?
    private(set) var secondaryTitle: TextProvider?

    init(_ events: Set<WCSessionSupportedEvent>) {
        bindPrimaryTitle()
        bindSecondaryTitle(events)
    }
}

extension WCSessionSupportedEventsAdvancedPermissionViewModel {
    private mutating func bindPrimaryTitle() {
        primaryTitle =
            "wc-session-supported-events"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindSecondaryTitle(_ events: Set<WCSessionSupportedEvent>) {
        let aTitle: String = events.map(\.rawValue).sorted().joined(separator: ", ")
        secondaryTitle = aTitle.bodyRegular(lineBreakMode: .byTruncatingTail)
    }
}
