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
//   TransactionTextInformationViewModel.swift

import Foundation
import MacaroonUIKit

final class TransactionTextInformationViewModel: ViewModel {
    private(set) var title: String?
    private(set) var detail: String?

    init(_ draft: TitledInformation) {
        title = draft.title
        detail = draft.detail
    }

    init(
        title: String?,
        detail: String?
    ) {
        self.title = title
        self.detail = detail
    }

    init(title: String?) {
        self.title = title
    }

    init(detail: String?) {
        self.detail = detail
    }
}
