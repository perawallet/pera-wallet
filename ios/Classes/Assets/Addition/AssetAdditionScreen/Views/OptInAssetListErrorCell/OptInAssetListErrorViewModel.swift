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

//   OptInAssetListErrorViewModel.swift

import Foundation
import MacaroonUIKit

struct OptInAssetListErrorViewModel: NoContentWithActionViewModel {
    typealias Error = OptInAssetList.ErrorItem

    private(set) var icon: Image?
    private(set) var title: TextProvider?
    private(set) var body: TextProvider?
    private(set) var primaryAction: Action?
    private(set) var secondaryAction: Action?

    init(error: Error) {
        bindIcon()
        bindTitle(error: error)
        bindBody(error: error)
        bindPrimaryAction()
        bindSecondaryAction()
    }
}

extension OptInAssetListErrorViewModel {
    mutating func bindIcon() {
        icon = nil
    }

    mutating func bindTitle(error: Error) {
        title = error.title.unwrap {
            $0.bodyMedium(alignment: .center)
        }
    }

    mutating func bindBody(error: Error) {
        body = error.body.unwrap {
            $0.footnoteRegular(alignment: .center)
        }
    }

    mutating func bindPrimaryAction() {
        primaryAction = (.string("title-retry".localized), nil)
    }

    mutating func bindSecondaryAction() {
        secondaryAction = nil
    }
}
