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
//   ListErrorViewModel.swift

import Foundation
import MacaroonUIKit

struct ListErrorViewModel: NoContentWithActionViewModel {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var body: EditText?
    private(set) var actionTitle: EditText?

    init() {
        bindIcon()
        bindTitle()
        bindBody()
        bindActionTitle()
    }
}

extension ListErrorViewModel {
    private mutating func bindIcon() {
        icon = "icon-warning-error"
    }

    private mutating func bindTitle() {
        title = .string("transaction-filter-error-title".localized)
    }

    private mutating func bindBody() {
        body = .string("transaction-filter-error-subtitle".localized)
    }

    private mutating func bindActionTitle() {
        actionTitle = .string("transaction-filter-try-again".localized)
    }
}
