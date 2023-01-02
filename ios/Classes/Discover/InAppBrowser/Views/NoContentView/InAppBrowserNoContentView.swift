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

//   InAppBrowserNoContentView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class InAppBrowserNoContentView:
    MacaroonUIKit.BaseView,
    UIInteractable {
    var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .retry : UIBlockInteraction()
    ]

    private lazy var contentView = UIView()

    private var state: State?
    private var contextView: UIView?

    init(_ theme: InAppBrowserNoContentViewTheme = .init()) {
        super.init(frame: .zero)
        addUI(theme)
    }
}

extension InAppBrowserNoContentView {
    func setState(
        _ state: State?,
        animated: Bool
    ) {
        updateUI(
            for: state,
            animated: animated
        ) { [weak self] isCompleted in
            guard let self else { return }

            if isCompleted {
                self.state = state
            }
        }
    }
}

extension InAppBrowserNoContentView {
    private func addUI(_ theme: InAppBrowserNoContentViewTheme) {
        addBackground(theme)
        addContent(theme)
    }

    typealias UpdateUICompletion = (Bool) -> Void
    private func updateUI(
        for someState: State?,
        animated: Bool,
        completion: @escaping UpdateUICompletion
    ) {
        if someState == state {
            updateUIForOldState(completion: completion)
        } else {
            updateUIForNewState(
                someState,
                animated: animated,
                completion: completion
            )
        }
    }

    private func updateUIForOldState(completion: UpdateUICompletion) {
        defer { completion(true) }

        guard let contextView else { return }

        if let loadingView = contextView as? InAppBrowserLoadingView {
            loadingView.startAnimating()
        }
    }

    private func updateUIForNewState(
        _ state: State?,
        animated: Bool,
        completion: @escaping UpdateUICompletion
    ) {
        let oldContextView = contextView
        let newContextView = createContext(for: state)
        let transition = {
            [unowned self] in
            self.removeContext(oldContextView)
            self.addContext(newContextView)
        }
        let transitionCompletion: (Bool) -> Void = {
            [weak self] isCompleted in
            guard let self else { return }

            self.contextView = isCompleted ? newContextView : oldContextView
            completion(isCompleted)
        }

        if animated {
            UIView.transition(
                with: self,
                duration: 0.2,
                options: .transitionCrossDissolve,
                animations: transition,
                completion: transitionCompletion
            )
        } else {
            transition()
            transitionCompletion(true)
        }
    }

    private func addBackground(_ theme: InAppBrowserNoContentViewTheme) {
        customizeAppearance(theme.background)
    }

    private func addContent(_ theme: InAppBrowserNoContentViewTheme) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == safeAreaInsets.top + theme.contentEdgeInsets.top
            $0.leading == safeAreaInsets.left + theme.contentEdgeInsets.leading
            $0.bottom == safeAreaInsets.bottom + theme.contentEdgeInsets.bottom
            $0.trailing == safeAreaInsets.right + theme.contentEdgeInsets.trailing
        }
    }

    private func addContext(_ view: UIView?) {
        guard let view else { return }

        contentView.addSubview(view)
        view.snp.makeConstraints {
            $0.top == safeAreaInsets.top
            $0.leading == safeAreaInsets.left
            $0.bottom == safeAreaInsets.bottom
            $0.trailing == safeAreaInsets.right
        }
    }

    private func removeContext(_ view: UIView?) {
        guard let view else { return }
        view.removeFromSuperview()
    }

    private func createContext(for state: State?) -> UIView? {
        switch state {
        case .none:
            return nil
        case .loading(let theme):
            return createLoading(theme)
        case .error(let theme, let viewModel):
            return createError(
                theme,
                viewModel
            )
        }
    }

    private func createLoading(_ theme: InAppBrowserLoadingViewTheme) -> InAppBrowserLoadingView {
        let view = InAppBrowserLoadingView(theme)
        view.startAnimating()
        return view
    }

    private func createError(
        _ theme: DiscoverErrorViewTheme,
        _ viewModel: InAppBrowserErrorViewModel
    ) -> DiscoverErrorView {
        let view = DiscoverErrorView(theme)
        view.bindData(viewModel)
        view.startObserving(event: .retry) {
            [unowned self] in
            let interaction = self.uiInteractions[.retry]
            interaction?.publish()
        }
        return view
    }
}

extension InAppBrowserNoContentView {
    enum State: Equatable {
        case loading(InAppBrowserLoadingViewTheme)
        case error(DiscoverErrorViewTheme, InAppBrowserErrorViewModel)

        static func == (
            lhs: State,
            rhs: State
        ) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.error(_, let lhsViewModel), .error(_, let rhsViewModel)):
                return lhsViewModel == rhsViewModel
            default:
                return false
            }
        }
    }
}

extension InAppBrowserNoContentView {
    enum Event {
        case retry
    }
}
