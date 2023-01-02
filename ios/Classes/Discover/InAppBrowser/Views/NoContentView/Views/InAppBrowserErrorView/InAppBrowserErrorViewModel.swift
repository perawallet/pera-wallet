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

//   InAppBrowserErrorViewModel.swift

import Foundation
import MacaroonUIKit
import MagpieCore

struct InAppBrowserErrorViewModel:
    DiscoverErrorViewModel,
    Equatable {
    private(set) var icon: Image?
    private(set) var title: TextProvider?
    private(set) var body: TextProvider?

    init(error: Error) {
        if let connectionError = (error as? URLError).unwrap(ConnectionError.init) {
            bind(error: connectionError)
        } else {
            let unexpectedError = UnexpectedError(responseData: nil, underlyingError: nil)
            bind(error: unexpectedError)
        }
    }
}

extension InAppBrowserErrorViewModel {
    mutating func bind(error: ConnectionError) {
        bindIcon()
        bindTitle(error: error)
        bindBody(error: error)
    }

    mutating func bindTitle(error: ConnectionError) {
        bindTitle(string: "discover-error-connection-title".localized)
    }

    mutating func bindBody(error: ConnectionError) {
        bindBody(string: "discover-error-connection-body".localized)
    }
}

extension InAppBrowserErrorViewModel {
    mutating func bind(error: UnexpectedError) {
        bindIcon()
        bindTitle(error: error)
        bindBody(error: error)
    }

    mutating func bindTitle(error: UnexpectedError) {
        bindTitle(string: "title-generic-api-error".localized)
    }

    mutating func bindBody(error: UnexpectedError) {
        bindBody(string: "\("discover-error-fallback-body".localized)\n\("title-retry-later".localized)")
    }
}

extension InAppBrowserErrorViewModel {
    mutating func bindIcon() {
        icon = "icon-info-square".templateImage
    }

    mutating func bindTitle(string: String?) {
        title = string?.bodyMedium(alignment: .center)
    }

    mutating func bindBody(string: String?) {
        body = string?.footnoteRegular(alignment: .center)
    }
}

extension InAppBrowserErrorViewModel {
    static func == (
        lhs: InAppBrowserErrorViewModel,
        rhs: InAppBrowserErrorViewModel
    ) -> Bool {
        return
            lhs.title?.string == rhs.title?.string &&
            lhs.body?.string == rhs.body?.string
    }
}
