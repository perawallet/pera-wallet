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

//   WebImportErrorViewModel.swift

import Foundation
import MacaroonUIKit

struct WebImportErrorViewModel: ResultViewModel {
    private(set) var icon: Image?
    private(set) var title: TextProvider?
    private(set) var body: TextProvider?

    init(error: ImportAccountScreenError) {
        bindIcon()
        bindTitle()
        bindBody(with: error)
    }
}

extension WebImportErrorViewModel {
    private mutating func bindIcon() {
        icon = "icon-error-close"
    }

    private mutating func bindTitle() {
        title = "title-generic-error".localized.titleMedium()
    }

    private mutating func bindBody(with error: ImportAccountScreenError) {
        switch error {
        case .unsupportedVersion(let qrVersion):
            if qrVersion != "1" {
                bindUnsupportedVersionBody(qrVersion)
            } else {
                bindGenericBody()
            }
        default:
            bindGenericBody()
        }

    }

    private mutating func bindUnsupportedVersionBody(_ qrVersion: String) {
        body =
            "web-import-error-unsupported-version-body"
                .localized(params: qrVersion)
                .bodyRegular()
    }

    private mutating func bindGenericBody() {
        body = "web-import-error-body".localized.bodyRegular()
    }
}
