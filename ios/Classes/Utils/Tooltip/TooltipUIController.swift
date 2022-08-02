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

//   TooltipUIController.swift

import Foundation
import UIKit
import MacaroonUIKit
import SnapKit

final class TooltipUIController {
    private var isPresenting = false
    private var contentView: UIView?

    private unowned let presentingView: UIView

    private let theme: TooltipViewTheme

    private var currentContentLayoutAnimator: UIViewPropertyAnimator?

    private var contentStartLayout: [Constraint] = []
    private var contentEndLayout: [Constraint] = []

    init(
        presentingView: UIView,
        theme: TooltipViewTheme = .init()
    ) {
        self.presentingView = presentingView
        self.theme = theme
    }

    func present(
        on sourceView: UIView,
        title: String,
        duration: TooltipDuration? = nil
    ) {
        if let currentContentLayoutAnimator = currentContentLayoutAnimator,
           currentContentLayoutAnimator.isRunning {
            currentContentLayoutAnimator.isReversed.toggle()
            return
        }

        if isPresenting {
            return
        }
        
        contentView = addContent(
            adjustedFor: sourceView,
            with: TooltipViewModel(title)
        )

        presentingView.layoutIfNeeded()

        updateLayoutWhenPresentingStatusDidChange(isPresenting: true)
        currentContentLayoutAnimator = makeContentAnimator(isPresenting: true)

        currentContentLayoutAnimator?.addCompletion {
            [weak self] position in
            guard let self = self else { return }

            switch position {
            case .start:
                self.updateContentLayoutWhenPresentingStatusDidChange(isPresenting: false)
            case .end:
                self.isPresenting = true

                guard let duration = duration else {
                    return
                }

                self.dismissAfter(
                    duration: duration
                )
            default:
                break
            }
        }

        currentContentLayoutAnimator?.startAnimation()
    }

    func dismissAfter(
        duration: TooltipDuration,
        execute: (() -> Void)? = .none
    ) {
        if !isPresenting {
            return
        }

        let time: DispatchTime = .now() + duration.seconds
        DispatchQueue.main.asyncAfter(deadline: time) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.dismiss(
                execute: execute
            )
        }
    }

    func dismiss(
        execute: (() -> Void)? = .none
    ) {
        if let currentContentLayoutAnimator = currentContentLayoutAnimator,
           currentContentLayoutAnimator.isRunning {
            currentContentLayoutAnimator.isReversed.toggle()
            return
        }

        if !isPresenting {
            return
        }

        updateLayoutWhenPresentingStatusDidChange(isPresenting: false)
        currentContentLayoutAnimator = makeContentAnimator(isPresenting: false)

        currentContentLayoutAnimator?.addCompletion {
            [weak self] position in
            guard let self = self else { return }

            switch position {
            case .start:
                self.updateLayoutWhenPresentingStatusDidChange(isPresenting: true)
            case .end:
                self.removeLayout()
                self.isPresenting = false
                execute?()
            default:
                break
            }
        }

        currentContentLayoutAnimator?.startAnimation()
    }
}

extension TooltipUIController {
    private func addContent(
        adjustedFor sourceView: UIView,
        with viewModel: TooltipViewModel
    ) -> UIView {
        let arrowLocationX = sourceView.window!.convert(
            sourceView.frame,
            from: sourceView.superview
        ).midX

        let contentView = TooltipView(
            arrowLocationX: arrowLocationX
        )
        contentView.bindData(viewModel)

        presentingView.addSubview(contentView)

        presentingView.layoutIfNeeded()

        contentView.snp.makeConstraints {
            $0.centerX
                .equalTo(sourceView)
                .priority(.low)
            $0.leading >= theme.contentHorizontalMargins.leading
            $0.trailing <= theme.contentHorizontalMargins.trailing
        }

        contentView.snp.prepareConstraints {
            contentStartLayout =  [
                $0.bottom == sourceView.snp.top - theme.contentBottomMargin
            ]
            contentEndLayout = [
                $0.bottom == sourceView.snp.top + theme.contentBottomMargin
            ]
        }

        updateContentLayoutWhenPresentingStatusDidChange(
            isPresenting: false
        )
        updateContentAlongsideAnimations(
            isPresenting: false
        )

        return contentView
    }
}

extension TooltipUIController {
    private func makeContentAnimator(
        isPresenting: Bool
    ) -> UIViewPropertyAnimator {
        let animator =  UIViewPropertyAnimator(
            duration: 0.353,
            timingParameters: UISpringTimingParameters(
                mass: 1,
                stiffness: 528,
                damping: 34,
                initialVelocity: CGVector(dx: 0, dy: 0)
            )
        )

        animator.addAnimations {
            [weak self] in
            guard let self = self else {
                return
            }

            self.presentingView.layoutIfNeeded()

            self.updateContentAlongsideAnimations(
                isPresenting: isPresenting
            )
        }

        return animator
    }
}
extension TooltipUIController {
    private func updateLayoutWhenPresentingStatusDidChange(
        isPresenting: Bool
    ) {
        updateContentLayoutWhenPresentingStatusDidChange(
            isPresenting: isPresenting
        )
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

    private func updateContentAlongsideAnimations(
        isPresenting: Bool
    ) {
        contentView?.alpha = isPresenting ? 1 : 0
    }

    private func removeLayout() {
        removeContent()
    }

    private func removeContent() {
        contentView?.removeFromSuperview()
        contentView = nil

        contentStartLayout = []
        contentEndLayout = []
    }
}

struct TooltipDuration {
    let seconds: Double

    static let `default` = TooltipDuration(seconds: 2)
}
