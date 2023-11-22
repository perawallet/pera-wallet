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

//   WCSessionSupportedMethodsAdvancedPermissionViewModel.swift

import Foundation
import MacaroonUIKit

struct WCSessionSupportedMethodsAdvancedPermissionViewModel: PrimaryTitleViewModel {
    private(set) var primaryTitle: TextProvider?
    private(set) var primaryTitleAccessory: Image?
    private(set) var secondaryTitle: TextProvider?

    init(_ methods: Set<WCSessionSupportedMethod>) {
        bindPrimaryTitle()
        bindSecondaryTitle(methods)
    }
}

extension WCSessionSupportedMethodsAdvancedPermissionViewModel {
    private mutating func bindPrimaryTitle() {
        primaryTitle =
            "wc-session-supported-methods"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindSecondaryTitle(_ methods: Set<WCSessionSupportedMethod>) {
        let aTitle: String = methods.map(\.rawValue).sorted().joined(separator: ", ")
        secondaryTitle = aTitle.bodyRegular(lineBreakMode: .byTruncatingTail)
    }
}
