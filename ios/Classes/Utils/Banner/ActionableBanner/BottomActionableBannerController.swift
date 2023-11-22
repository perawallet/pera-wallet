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

//   BottomActionableBannerController.swift

import Foundation
import SnapKit
import UIKit
import MacaroonUIKit

final class BottomActionableBannerController {
    private var isPresenting = false
    private var contentView: UIView?

    private unowned let presentingView: UIView

    var configuration: BottomActionableBannerControllerConfiguration

    private var currentContentLayoutAnimator: UIViewPropertyAnimator?

    private var contentStartLayout: [Constraint] = []
    private var contentEndLayout: [Constraint] = []

    init(
        presentingView: UIView,
        configuration: BottomActionableBannerControllerConfiguration = .default
    ) {
        self.presentingView = presentingView
        self.configuration = configuration
    }

    private func presentError(
        with view: UIView
    ) {
        if let currentContentLayoutAnimator = currentContentLayoutAnimator,
           currentContentLayoutAnimator.isRunning {
            currentContentLayoutAnimator.isReversed.toggle()
            return
        }

        if isPresenting {
            return
        }

        addContent(view)

        presentingView.layoutIfNeeded()

        updateLayoutWhenPresentingStatusDidChange(isPresenting: true)
        currentContentLayoutAnimator = makeContentLayoutAnimator(isPresenting: true)

        currentContentLayoutAnimator?.addCompletion {
            [weak self] position in
            guard let self = self else { return }

            switch position {
            case .start:
                self.updateContentLayoutWhenPresentingStatusDidChange(isPresenting: false)
            case .end:
                self.isPresenting = true
            default:
                break
            }
        }

        currentContentLayoutAnimator?.startAnimation()
    }

    func dismissError() {
        if let currentContentLayoutAnimator = currentContentLayoutAnimator,
           currentContentLayoutAnimator.isRunning {
            currentContentLayoutAnimator.isReversed.toggle()
            return
        }

        if !isPresenting {
            return
        }

        updateLayoutWhenPresentingStatusDidChange(isPresenting: false)
        currentContentLayoutAnimator = makeContentLayoutAnimator(isPresenting: false)

        currentContentLayoutAnimator?.addCompletion {
            [weak self] position in
            guard let self = self else { return }

            switch position {
            case .start:
                self.updateLayoutWhenPresentingStatusDidChange(isPresenting: true)
            case .end:
                self.removeLayout()
                self.isPresenting = false
            default:
                break
            }
        }

        currentContentLayoutAnimator?.startAnimation()
    }
}

extension BottomActionableBannerController {
    private func makeContentLayoutAnimator(
        isPresenting: Bool
    ) -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator(
            duration: 0.3,
            curve: .easeInOut
        ) { [unowned self] in
            presentingView.layoutIfNeeded()
        }
    }
}

extension BottomActionableBannerController {
    private func updateLayoutWhenPresentingStatusDidChange(
        isPresenting: Bool
    ) {
        updateContentLayoutWhenPresentingStatusDidChange(
            isPresenting: isPresenting
        )
    }

    private func removeLayout() {
        removeContent()
    }

    private func addContent(
        _ view: UIView
    ) {
        presentingView.addSubview(
            view
        )

        view.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
        }

        view.snp.prepareConstraints {
            contentStartLayout =  [
                $0.bottom == presentingView.snp.bottom - configuration.bottomMargin
            ]
            contentEndLayout = [
                $0.top == presentingView.snp.bottom
            ]
        }

        updateLayoutWhenPresentingStatusDidChange(
            isPresenting: false
        )

        contentView = view
    }

    private func updateContentLayoutWhenPresentingStatusDidChange(
        isPresenting: Bool
    ) {
        let currentLayout: [Constraint]
        let nextLayout: [Constraint]

        if isPresenting {
            currentLayout = contentEndLayout
            nextLayout = contentStartLayout
        } else {
            currentLayout = contentStartLayout
            nextLayout = contentEndLayout
        }

        currentLayout.deactivate()
        nextLayout.activate()
    }

    private func removeContent() {
        contentView?.removeFromSuperview()
        contentView = nil

        contentStartLayout = []
        contentEndLayout = []
    }
}

extension BottomActionableBannerController {
    func presentFetchError(
        icon: UIImage = "icon-info-24".uiImage,
        title: String,
        message: String,
        actionTitle: String? = nil,
        actionHandler: (() -> Void)? = nil
    ) {
        let view = makeFetchErrorBanner(
            icon: icon,
            title: title,
            message: message,
            actionTitle: actionTitle,
            actionHandler: actionHandler,
            contentBottomPadding: configuration.contentBottomPadding
        )

        presentError(
            with: view
        )
    }

    private func makeFetchErrorBanner(
        icon: UIImage = "icon-info-24".uiImage,
        title: String,
        message: String,
        actionTitle: String? = nil,
        actionHandler: (() -> Void)? = nil,
        contentBottomPadding: LayoutMetric
    ) -> ActionableBannerView {
        let view = ActionableBannerView()
      
        let theme = ActionableBannerViewTheme(
            .current,
            contentBottomPadding: contentBottomPadding
        )
        view.customize(theme)
      
        let draft = ActionableBannerDraft(
            icon: icon,
            title: title,
            message: message,
            actionTitle: actionTitle
        )
        let viewModel = FetchErrorActionableBannerViewModel(draft)
        view.bindData(viewModel)

        if let actionHandler = actionHandler {
            view.startObserving(
                event: .performAction,
                using: actionHandler
            )
        }

        return view
    }
}
