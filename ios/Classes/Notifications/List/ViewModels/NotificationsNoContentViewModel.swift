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
//   NotificationsNoContentViewModel.swift

import MacaroonUIKit

struct NotificationsNoContentViewModel: NoContentViewModel {
    private(set) var icon: Image?
    private(set) var title: TextProvider?
    private(set) var body: TextProvider?

    init() {
        bindImage()
        bindTitle()
        bindBody()
    }
}

extension NotificationsNoContentViewModel {
    private mutating func bindImage() {
        icon = "img-nc-empty"
    }

    private mutating func bindTitle() {
        title = "notifications-empty-title".localized
    }

    private mutating func bindBody() {
        body = "notifications-empty-subtitle".localized
    }
}
