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

//   CollectibleExternalSourceViewModel.swift

import Foundation
import MacaroonUIKit

struct CollectibleExternalSourceViewModel:
    ViewModel,
    Hashable {
    private(set) var source: CollectibleExternalSource?
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var action: Image?

    init(
        _ source: CollectibleExternalSource
    ) {
        bindSource(source)
        bindIcon(source)
        bindTitle(source)
        bindAction()
    }
}

extension CollectibleExternalSourceViewModel {
    private mutating func bindSource(
        _ source: CollectibleExternalSource
    ) {
        self.source = source
    }

    private mutating func bindIcon(
        _ source: CollectibleExternalSource
    ) {
        icon = source.image
    }

    private mutating func bindTitle(
        _ source: CollectibleExternalSource
    ) {
        title = .attributedString(
            source.title
                .bodyRegular()
        )
    }

    private mutating func bindAction() {
        action = img("icon-external-link")
    }
}

extension CollectibleExternalSourceViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(title)
        hasher.combine(icon?.uiImage)
        hasher.combine(action?.uiImage)
    }

    static func == (
        lhs: CollectibleExternalSourceViewModel,
        rhs: CollectibleExternalSourceViewModel
    ) -> Bool {
        return lhs.title == rhs.title &&
            lhs.icon?.uiImage == rhs.icon?.uiImage &&
            lhs.action?.uiImage == rhs.action?.uiImage
    }
}
