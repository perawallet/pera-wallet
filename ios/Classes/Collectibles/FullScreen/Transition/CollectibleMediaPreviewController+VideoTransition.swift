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

//   CollectibleMediaPreviewController+VideoTransition.swift

import Foundation
import UIKit

extension CollectibleMediaPreviewViewController {
    final class VideoTransitionDelegate:
        NSObject,
        UIViewControllerTransitioningDelegate {
        var didFinishDismissalTransition: (() -> Void)?

        func animationController(
            forPresented presented: UIViewController,
            presenting: UIViewController,
            source: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            return VideoTransitionAnimator(
                transition: .presentation
            )
        }

        func animationController(
            forDismissed dismissed: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            let animator = VideoTransitionAnimator(
                transition: .dismissal
            )
            animator.didFinishDismissalTransition = didFinishDismissalTransition
            return animator
        }
    }
}

extension CollectibleMediaPreviewViewController {
    final class VideoTransitionAnimator:
        NSObject,
        UIViewControllerAnimatedTransitioning {
        enum Transition {
            case presentation
            case dismissal
        }

        private let duration: Double
        private let transition: Transition

        var didFinishDismissalTransition: (() -> Void)?

        init(
            duration: Double = 0.3,
            transition: Transition
        ) {
            self.duration = duration
            self.transition = transition
        }

        func transitionDuration(
            using transitionContext: UIViewControllerContextTransitioning?
        ) -> TimeInterval {
            return duration
        }

        func animateTransition(
            using transitionContext: UIViewControllerContextTransitioning
        ) {
            guard let toViewController = transitionContext.destinationViewController,
                  let fromViewController = transitionContext.sourceViewController else {
                transitionContext.completeTransition(false)
                return
            }

            switch transition {
            case .presentation:
                makePresentationAnimation(
                    using: transitionContext,
                    fromViewController: fromViewController,
                    toViewController: toViewController
                )
            case .dismissal:
                makeDismissalAnimation(
                    using: transitionContext,
                    fromViewController: fromViewController,
                    toViewController: toViewController
                )
            }
        }

        private func makePresentationAnimation(
            using transitionContext: UIViewControllerContextTransitioning,
            fromViewController: UIViewController,
            toViewController: UIViewController
        ) {
            guard let fromViewController =
                    (fromViewController as? NavigationContainer)?.topViewController as? CollectibleDetailViewController,
                  let toViewController = toViewController as? CollectibleFullScreenVideoViewController,
                  let fromVideoPreviewCell = fromViewController.currentVisibleMediaCell as? CollectibleMediaVideoPreviewCell else {
                transitionContext.completeTransition(false)
                return
            }

            toViewController.view.layoutIfNeeded()
            toViewController.view.isHidden = true

            let fromVideoPlayerView = fromVideoPreviewCell.contextView.videoPlayerView

            let containerView = transitionContext.containerView

            let contentView = UIView()
            contentView.backgroundColor = .black
            contentView.frame = toViewController.view.frame
            contentView.alpha = 0

            guard let videoPlayerViewSnapshot = fromVideoPlayerView.snapshotView(afterScreenUpdates: false) else {
                transitionContext.completeTransition(false)
                return
            }

            videoPlayerViewSnapshot.frame = containerView.convert(
                videoPlayerViewSnapshot.frame,
                from: fromVideoPreviewCell
            )

            [
                toViewController.view,
                contentView,
                videoPlayerViewSnapshot
            ].forEach {
                containerView.addSubview($0)
            }

            let duration = transitionDuration(using: transitionContext)

            fromVideoPreviewCell.isHidden = true

            let animator = UIViewPropertyAnimator(
                duration: duration,
                curve: .easeInOut
            ) {
                contentView.alpha = 1
                videoPlayerViewSnapshot.frame = containerView.convert(
                    toViewController.contentView.frame,
                    from: toViewController.view
                )
            }

            animator.addCompletion { position in
                toViewController.view.isHidden = false

                videoPlayerViewSnapshot.removeFromSuperview()
                contentView.removeFromSuperview()

                transitionContext.completeTransition(
                    !transitionContext.transitionWasCancelled
                )
            }

            animator.startAnimation()
        }

        private func makeDismissalAnimation(
            using transitionContext: UIViewControllerContextTransitioning,
            fromViewController: UIViewController,
            toViewController: UIViewController
        ) {
            guard let fromViewController = fromViewController as? CollectibleFullScreenVideoViewController,
                  let toViewController =
                    (toViewController as? NavigationContainer)?.topViewController as? CollectibleDetailViewController,
                  let toVideoPreviewCell = toViewController.currentVisibleMediaCell as? CollectibleMediaVideoPreviewCell,
                  let videoPlayerViewSnapshot = fromViewController.videoPlayerView.snapshotView(afterScreenUpdates: false) else {
                transitionContext.completeTransition(false)
                return
            }

            let containerView = transitionContext.containerView

            videoPlayerViewSnapshot.frame = containerView.convert(
                fromViewController.contentView.frame,
                from: fromViewController.view

            )
            containerView.addSubview(videoPlayerViewSnapshot)

            toVideoPreviewCell.isHidden = true

            let duration = transitionDuration(using: transitionContext)
            let animator = UIViewPropertyAnimator(
                duration: duration,
                curve: .easeInOut
            ) {
                videoPlayerViewSnapshot.frame = containerView.convert(
                    toVideoPreviewCell.contextView.videoPlayerView.frame,
                    from: toVideoPreviewCell
                )

                fromViewController.view.alpha = 0
            }

            fromViewController.contentView.isHidden = true

            animator.addCompletion {
                [weak self] position in
                toVideoPreviewCell.isHidden = false

                videoPlayerViewSnapshot.removeFromSuperview()

                self?.didFinishDismissalTransition?()

                transitionContext.completeTransition(
                    !transitionContext.transitionWasCancelled
                )
            }

            animator.startAnimation()
        }
    }
}
