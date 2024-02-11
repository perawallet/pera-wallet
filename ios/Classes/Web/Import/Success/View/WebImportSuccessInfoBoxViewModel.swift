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

//   WebImportSuccessInfoBoxViewModel.swift

import Foundation
import MacaroonUIKit

struct WebImportSuccessInfoBoxViewModel: InfoBoxViewModel {
    var icon: Image?
    var title: TextProvider?
    var message: TextProvider?
    var style: InfoBoxViewStyle?

    init(unimportedAccountCount: Int) {
        bindIcon()
        bindTitle(unimportedAccountCount: unimportedAccountCount)
        bindMessage(unimportedAccountCount: unimportedAccountCount)
        bindStyle()
    }
}

extension WebImportSuccessInfoBoxViewModel {
    private mutating func bindIcon() {
        icon = "icon-info-positive"
    }

    private mutating func bindTitle(unimportedAccountCount: Int) {
        let isSingular = unimportedAccountCount == 1
        let title = isSingular ? "web-import-success-unimported-singular-title".localized(params: "\(unimportedAccountCount)") : "web-import-success-unimported-title".localized(params: "\(unimportedAccountCount)")

        self.title = title.footnoteMedium()
    }

    private mutating func bindMessage(unimportedAccountCount: Int) {
        let isSingular = unimportedAccountCount == 1
        let message = isSingular ? "web-import-success-unimported-singular-body".localized(params: "\(unimportedAccountCount)") : "web-import-success-unimported-body".localized(params: "\(unimportedAccountCount)")

        self.message = message.footnoteRegular()
    }

    private mutating func bindStyle() {
        style = InfoBoxViewStyle(
            background: [
                .backgroundColor(Colors.Helpers.positiveLighter)
            ],
            corner: Corner(radius: 8)
        )
    }
}
