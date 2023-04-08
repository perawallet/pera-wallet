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
    init(
        presentingView: UIView
    ) {
        super.init(presentingView: presentingView)

        configuration.contentHorizontalPaddings = (24, 24)
        configuration.contentTopPadding = presentingView.safeAreaInsets.top + 12

        activate()
    }
}

extension BannerController {
    func present(_ error: ErrorDisplayable) {
        if !error.isValid { return }

        presentErrorBanner(
            title: error.title,
            message: error.message
        )
    }
}

extension BannerController {
    func presentErrorBanner(
        title: String,
        message: String,
        _ completion: (() -> Void)? = nil
    ) {
        let view = makeErrorBanner()
        let viewModel = BannerErrorViewModel(
            title: title,
            message: message
        )
        view.bindData(viewModel)

        view.startObserving(event: .performAction) {
            completion?()
        }

        enqueue(view)
    }

    func presentSuccessBanner(
        title: String,
        message: String? = nil
    ) {
        let view = makeSuccessBanner()
        let viewModel = BannerSuccessViewModel(
            title: title,
            message: message
        )
        view.bindData(viewModel)

        enqueue(view)
    }

    func presentInAppNotification(
        _ title: String,
        _ completion: (() -> Void)? = nil
    ) {
        let view = makeInAppNotificationBanner()
        let viewModel = BannerInAppNotificationViewModel(title: title)
        view.bindData(viewModel)

        view.startObserving(event: .performAction) {
            completion?()
        }

        enqueue(view)
    }

    func presentInfoBanner(
        _ title: String,
        _ completion: (() -> Void)? = nil
    ) {
        let view = makeInfoBanner()
        let viewModel = BannerInfoViewModel(title: title)
        view.bindData(viewModel)

        view.startObserving(event: .performAction) {
            completion?()
        }

        enqueue(view)
    }
}

extension BannerController {
    private func makeErrorBanner() -> BannerView {
        let view = BannerView()
        let theme = BannerViewTheme()
        view.customize(theme)
        return view
    }

    private func makeSuccessBanner() -> BannerView {
        let view = BannerView()
        var theme = BannerViewTheme()
        theme.configureForSuccess()
        view.customize(theme)
        return view
    }

    private func makeInAppNotificationBanner() -> BannerView {
        let view = BannerView()
        var theme = BannerViewTheme()
        theme.configureForInAppNotification()
        view.customize(theme)
        return view
    }

    private func makeInfoBanner() -> BannerView {
        let view = BannerView()
        var theme = BannerViewTheme()
        theme.configureForInfo()
        view.customize(theme)
        return view
    }
}

protocol ErrorDisplayable {
    var title: String { get }
    var message: String { get }
}

extension ErrorDisplayable {
    var isValid: Bool {
        return !message.isEmpty
    }
}
