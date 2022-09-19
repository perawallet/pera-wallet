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

//   ReceiveCollectibleAssetListInfoViewModel.swift

import MacaroonUIKit

struct ReceiveCollectibleAssetListInfoViewModel: InfoBoxViewModel {
    var icon: Image?
    var title: TextProvider?
    var message: TextProvider?
    var style: InfoBoxViewStyle?

    init() {
        bindIcon()
        bindTitle()
        bindMessage()
        bindStyle()
    }
}

extension ReceiveCollectibleAssetListInfoViewModel {
    private mutating func bindIcon() {
        icon = "icon-info-positive"
    }

    private mutating func bindTitle() {
        title = nil
    }

    private mutating func bindMessage() {
        message = "collectible-receive-asset-list-info".localized.footnoteMedium()
    }

    private mutating func bindStyle() {
        style = InfoBoxViewStyle(
            background: [
                .backgroundColor(Colors.Helpers.positiveLighter)
            ],
            corner: Corner(radius: 4)
        )
    }
}
