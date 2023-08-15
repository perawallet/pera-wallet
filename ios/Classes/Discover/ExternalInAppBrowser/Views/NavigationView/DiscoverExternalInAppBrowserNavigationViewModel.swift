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

//   DiscoverExternalInAppBrowserNavigationViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit
import WebKit

struct DiscoverExternalInAppBrowserNavigationViewModel: ViewModel {
    private(set) var title: TextProvider?
    private(set) var subtitle: TextProvider?

    init(_ model: WKBackForwardListItem, title: String?) {
        bind(model, title: title)
    }

    init(_ model: DiscoverDappParamaters) {
        bind(model)
    }
    
    init(title: String?, subtitle: String?) {
        bind(title, subtitle)
    }
}

extension DiscoverExternalInAppBrowserNavigationViewModel {
    mutating func bind(_ model: WKBackForwardListItem, title: String?) {
        bindTitle(model, title: title)
        bindSubtitle(model)
    }

    mutating func bind(_ model: DiscoverDappParamaters) {
        bindTitle(model)
        bindSubtitle(model)
    }
    
    mutating func bind(_ title: String?, _ subtitle: String?) {
        bindTitle(title)
        bindSubtitle(subtitle)
    }
}

extension DiscoverExternalInAppBrowserNavigationViewModel {
    mutating func bindTitle(_ item: WKBackForwardListItem, title: String?) {
        let title = title ?? item.title

        self.title = title?.bodyMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }

    mutating func bindTitle(_ item: DiscoverDappParamaters) {
        let title = item.name

        self.title = title?.bodyMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }
    
    mutating func bindTitle(_ item: String?) {
        self.title = item?.bodyMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }

    mutating func bindSubtitle(_ item: WKBackForwardListItem) {
        let subtitle = item.url.presentationString

        self.subtitle = subtitle?.captionMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }

    mutating func bindSubtitle(_ item: DiscoverDappParamaters) {
        let subtitle = item.url.presentationString

        self.subtitle = subtitle?.captionMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }
    
    mutating func bindSubtitle(_ item: String?) {
        self.subtitle = item?.captionMedium(
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
    }
}
