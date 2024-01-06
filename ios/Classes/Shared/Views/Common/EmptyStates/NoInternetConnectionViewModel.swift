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
//   NoInternetConnectionViewModel.swift

import MacaroonUIKit

struct NoInternetConnectionViewModel: NoContentViewModel {
    private(set) var icon: Image?
    private(set) var title: TextProvider?
    private(set) var body: TextProvider?

    init() {
        bindImage()
        bindTitle()
        bindBody()
    }
}

extension NoInternetConnectionViewModel {
    private mutating func bindImage() {
        icon = "icon-no-internet-connection"
    }
    
    private mutating func bindTitle() {
        title =
            "internet-connection-error-title"
                .localized
                .bodyLargeMedium(
                    alignment: .center
                )
    }

    private mutating func bindBody() {
        body =
            "internet-connection-error-detail"
                .localized
                .bodyRegular(
                    alignment: .center
                )
    }
}
