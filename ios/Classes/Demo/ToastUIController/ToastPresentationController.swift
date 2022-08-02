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

//   ToastUIPresentationController.swift

import Foundation
import MacaroonToastUIKit
import MacaroonUIKit
import MacaroonUtils
import SnapKit
import UIKit

final class ToastPresentationController:
    ToastUIPresentationController,
    NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []

    convenience init(
        presentingView: UIView
    ) {
        var config = ToastUIConfiguration()
        config.minContentHorizontalEdgeInsets.leading = 24
        config.minContentHorizontalEdgeInsets.trailing = 24
        config.initialPresentingLayoutAttributes.offsetY = 20
        config.initialPresentingLayoutAttributes.alpha = 0
        config.initialPresentingLayoutAttributes.corner = 12
        config.finalPresentingLayoutAttributes.offsetY = 20
        config.finalPresentingLayoutAttributes.alpha = 1
        config.finalPresentingLayoutAttributes.corner = 12
        config.replacingLayoutAttributes.offsetY = 20
        config.replacingLayoutAttributes.alpha = 0.8
        config.replacingLayoutAttributes.corner = 12
        config.replacingLayoutAttributes.transform = CGAffineTransform(scaleX: 0.8, y: 0.6)
        config.dismissingLayoutAttributes.offsetY = 20
        config.dismissingLayoutAttributes.alpha = 0
        config.dismissingLayoutAttributes.corner = 12
        config.presentingAnimationDuration = 0.353
        config.presentingAnimationTimingParameters = UISpringTimingParameters(
            mass: 1,
            stiffness: 528,
            damping: 34,
            initialVelocity: .zero
        )
        config.replacingAnimationDuration = config.presentingAnimationDuration
        config.dismissingAnimationDuration = config.presentingAnimationDuration
        config.dismissingAnimationTimingParameters = config.presentingAnimationTimingParameters

        let layoutCalculator = ToastUILayoutCalculator(
            config: config,
            presentingView: presentingView
        )
        let animationController = ToastUIAnimationController(
            config: config,
            presentingView: presentingView,
            layoutCalculator: layoutCalculator
        )

        self.init(
            config: config,
            presentingView: presentingView,
            animationController: animationController
        )

        startObservingNotifications()
    }

    deinit {
        stopObservingNotifications()
    }
}

extension ToastPresentationController {
    func present(
        message: ToastViewModel
    ) {
        let theme = ToastViewTheme()
        let view = makeToast(theme)
        view.bindData(message)
        present(view)
    }

    func present(
        message: ToastViewModel,
        theme: ToastViewTheme
    ) {
        let view = makeToast(theme)
        view.bindData(message)
        present(view)
    }
}

extension ToastPresentationController {
    private func makeToast(
        _ theme: ToastViewTheme
    ) -> ToastView {
        let view = ToastView()
        view.customize(theme)
        return view
    }
}

extension ToastPresentationController {
    private func startObservingNotifications() {
        startObservingAppLifeCycleNotifications()
    }

    private func startObservingAppLifeCycleNotifications() {
        observeWhenApplicationWillResignActive {
            [weak self] _ in
            guard let self = self else { return }
            self.dismiss()
        }
    }
}
