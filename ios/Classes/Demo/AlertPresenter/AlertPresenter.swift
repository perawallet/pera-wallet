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

//   AlertPresenter.swift

import Foundation
import UIKit

final class AlertPresenter {
    private lazy var alertTransition = AlertUITransition(presentingViewController: presentingScreen)

    private var isCancelled = false
    private var isPresented = false

    private unowned let presentingScreen: UIViewController
    private unowned let session: Session
    private unowned let sharedDataController: SharedDataController
    private let items: [any AlertItem]

    init(
        presentingScreen: UIViewController,
        session: Session,
        sharedDataController: SharedDataController,
        items: [any AlertItem]
    ) {
        self.presentingScreen = presentingScreen
        self.session = session
        self.sharedDataController = sharedDataController
        self.items = items
    }

    func presentIfNeeded() {
        if !canDisplayItem() {
            return
        }

        isPresented = true

        guard let alertItemToPresent = items.getFirstDisplayableItem() else {
            return
        }

        alertTransition.perform(
            .alert(
                alert: alertItemToPresent.makeAlert()
            ),
            by: .presentWithoutNavigationController
        )

        
    }

    private func canDisplayItem() -> Bool {
        if isCancelled {
            return false
        }

        if isPresented {
            return false
        }

        let appLaunchStore = ALGAppLaunchStore()

        if !appLaunchStore.hasLaunchedOnce {
            cancel()
            return false
        }

        if !session.hasAuthentication() {
            return false
        }

        if !sharedDataController.isAvailable {
            return false
        }

        if sharedDataController.accountCollection.isEmpty {
            return false
        }

        let isUserOnAnotherTab =
            (presentingScreen.tabBarContainer?.selectedScreen as? UINavigationController)?
                .viewControllers
                .first != presentingScreen

        guard !isUserOnAnotherTab else {
            return false
        }

        /// <todo>
        /// Another naming?
        let isPresentingScreenPushedViewController =
            presentingScreen.navigationController?.topViewController != presentingScreen

        guard !isPresentingScreenPushedViewController else {
            return false
        }

        let isPresentingScreenPresentingModal = presentingScreen.presentedViewController != nil

        guard !isPresentingScreenPresentingModal else {
            return false
        }

        return true
    }

    private func cancel() {
        items.forEach {
            $0.cancel()
        }

        isCancelled = true
    }
}

private extension Array where Element == any AlertItem {
    func getFirstDisplayableItem() -> Element? {
        return first { $0.isAvailable }
    }
}
