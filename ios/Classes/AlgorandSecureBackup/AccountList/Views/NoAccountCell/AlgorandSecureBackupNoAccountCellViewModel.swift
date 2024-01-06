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

//   AlgorandSecureBackupNoAccountCellViewModel.swift

import Foundation
import MacaroonUIKit

struct AlgorandSecureBackupNoAccountCellViewModel: NoContentViewModel {
    var icon: Image?
    var title: TextProvider?
    var body: TextProvider?

    init() {
        bindBody()
    }

    private mutating func bindBody() {
        title = "algorand-secure-backup-account-list-no-content-body"
            .localized
            .bodyMedium(alignment: .center)
    }
}
