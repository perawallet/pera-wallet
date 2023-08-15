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

//   DiscoverExternalInAppBrowserNavigationView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class DiscoverExternalInAppBrowserNavigationView:
    View,
    ViewModelBindable {
    private lazy var titleView = Label()
    private lazy var subtitleView = Label()

    func customize(_ theme: DiscoverExternalInAppBrowserNavigationViewTheme) {
        addTitle(theme)
        addSubtitle(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func bindData(_ viewModel: DiscoverExternalInAppBrowserNavigationViewModel?) {
        viewModel?.title?.load(in: titleView)
        viewModel?.subtitle?.load(in: subtitleView)
    }
}

extension DiscoverExternalInAppBrowserNavigationView {
    private func addTitle(_ theme: DiscoverExternalInAppBrowserNavigationViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }

    private func addSubtitle(_ theme: DiscoverExternalInAppBrowserNavigationViewTheme) {
        subtitleView.customizeAppearance(theme.subtitle)

        addSubview(subtitleView)
        subtitleView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
