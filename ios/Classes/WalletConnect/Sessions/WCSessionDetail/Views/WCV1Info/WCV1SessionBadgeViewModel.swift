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

//   WCV1SessionBadgeViewModel.swift

import Foundation
import MacaroonUIKit

struct WCV1SessionBadgeViewModel: ViewModel {
    private(set) var badge: TextProvider?
    private(set) var info: TextProvider?

    init() {
        bindBadge()
        bindInfo()
    }
}

extension WCV1SessionBadgeViewModel {
    private mutating func bindBadge() {
        badge = "WCV1".captionMedium()
    }

    private mutating func bindInfo() {
        info =
            "wc-session-wcv1-info"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }
}
