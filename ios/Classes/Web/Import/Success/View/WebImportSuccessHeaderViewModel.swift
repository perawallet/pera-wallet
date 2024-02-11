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

//   WebImportSuccessHeaderViewModel.swift

import Foundation
import MacaroonUIKit

struct WebImportSuccessHeaderViewModel: NoContentViewModel {
    var icon: Image?
    var title: TextProvider?
    var body: TextProvider?

    init(importedAccountCount: Int) {
        bindIcon()
        bindTitle(for: importedAccountCount)
        bindBody(for: importedAccountCount)
    }
}

extension WebImportSuccessHeaderViewModel {
    private mutating func bindIcon() {
        icon = "check"
    }

    private mutating func bindTitle(for importedAccountCount: Int) {
        let isSingular = importedAccountCount == 1
        let resultTitle = isSingular ? "web-import-success-header-singular-title".localized : "web-import-success-header-title".localized
        title = resultTitle.titleMedium()
    }

    private mutating func bindBody(for importedAccountCount: Int) {
        let isSingular = importedAccountCount == 1
        let resultBody = isSingular ? "web-import-success-header-singular-body".localized(params: "\(importedAccountCount)") : "web-import-success-header-body".localized(params: "\(importedAccountCount)")
        body = resultBody.bodyRegular()
    }
}
