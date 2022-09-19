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

//   CollectibleListInfoWithFilterViewModel.swift

import MacaroonUIKit

struct CollectibleListInfoWithFilterViewModel:
    ViewModel,
    Hashable {
    private(set) var info: EditText?

    init(
        collectibleCount: Int
    ) {
        bindInfo(collectibleCount)
    }
}

extension CollectibleListInfoWithFilterViewModel {
    private mutating func bindInfo(
        _ collectibleCount: Int
    ) {
        let info: String

        if collectibleCount < 2 {
            info = "title-plus-collectible-singular-count".localized(params: "\(collectibleCount)")
        } else {
            info = "title-plus-collectible-count".localized(params: "\(collectibleCount)")
        }

        self.info = getInfo(info)
    }
}

extension CollectibleListInfoWithFilterViewModel {
    func getInfo(
        _ anInfo: String?
    ) -> EditText? {
        guard let anInfo = anInfo else {
            return nil
        }

        return .attributedString(
            anInfo
                .bodyMedium(
                    lineBreakMode: .byTruncatingTail
                )
        )
    }
}
