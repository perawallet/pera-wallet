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
//   BannerController.swift

import Foundation
import MacaroonBanner
import MacaroonUIKit
import UIKit

final class BannerController: MacaroonBanner.BannerController {
    init(window: UIWindow) {
        super.init(presentingView: window)

        configuration.contentHorizontalPaddings = (24, 24)
        configuration.contentTopPadding = window.safeAreaInsets.top + 12

        activate()
    }

    func presentErrorBanner(title: String, message: String, icon: UIImage? = img("icon-warning-circle")) {
        let bannerView = makeErrorBanner()
        let draft = BannerDraft(
            title: title,
            icon: icon,
            description: message
        )

        bannerView.bindData(
            BannerErrorViewModel(draft)
        )

        enqueue(bannerView)
    }

    func presentInfoBanner(_ title: String, _ completion: (() -> Void)? = nil) {
        let bannerView = makeInfoBanner()
        bannerView.bindData(BannerInfoViewModel(title))

        if completion != nil {
            bannerView.completion = completion
        }

        enqueue(bannerView)
    }
}

extension BannerController {
    private func makeErrorBanner() -> BannerView {
        let view = BannerView()
        view.customize(BannerViewErrorTheme())
        return view
    }

    private func makeInfoBanner() -> BannerView {
        let view = BannerView()
        view.customize(BannerViewInfoTheme())
        return view
    }
}
