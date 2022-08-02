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

//   CollectibleMediaPreviewViewController+ImageTransition.swift

import Foundation
import UIKit

extension CollectibleMediaPreviewViewController {
    final class ImageTransitionDelegate:
        NSObject,
        UIViewControllerTransitioningDelegate {
        func animationController(
            forPresented presented: UIViewController,
            presenting: UIViewController,
            source: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            return ImageTransitionAnimator(
                transition: .presentation
            )
        }

        func animationController(
            forDismissed dismissed: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            return ImageTransitionAnimator(
                transition: .dismissal
            )
        }
    }
}

extension CollectibleMediaPreviewViewController {
    final class ImageTransitionAnimator:
        NSObject,
        UIViewControllerAnimatedTransitioning {
        enum Transition {
            case presentation
            case dismissal
        }

        private let duration: Double
        private let transition: Transition

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
                  let toViewController = toViewController as? CollectibleFullScreenImageViewController,
                  let fromImageCell = fromViewController.currentVisibleMediaCell as? CollectibleMediaImagePreviewCell else {
                transitionContext.completeTransition(false)
                return
            }

            toViewController.view.layoutIfNeeded()
            toViewController.view.isHidden = true

            let fromImageView = fromImageCell.contextView.imageView

            let containerView = transitionContext.containerView

            let contentView = UIView()
            contentView.backgroundColor = .black
            contentView.frame = toViewController.view.frame
            contentView.alpha = 0

            guard let imageViewSnapshot = fromImageView.snapshotView(afterScreenUpdates: false) else {
                transitionContext.completeTransition(false)
                return
            }

            imageViewSnapshot.frame = containerView.convert(
                fromImageView.frame,
                from: fromImageCell
            )

            [
                toViewController.view,
                contentView,
                imageViewSnapshot
            ].forEach {
                containerView.addSubview($0)
            }

            let duration = transitionDuration(using: transitionContext)

            fromImageCell.isHidden = true

            let animator = UIViewPropertyAnimator(
                duration: duration,
                curve: .easeInOut
            ) {
                contentView.alpha = 1
                imageViewSnapshot.frame = containerView.convert(
                    toViewController.contentView.frame,
                    from: toViewController.view
                )
            }

            animator.addCompletion { position in
                toViewController.view.isHidden = false

                imageViewSnapshot.removeFromSuperview()
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
            guard let fromViewController = fromViewController as? CollectibleFullScreenImageViewController,
                  let toViewController =
                    (toViewController as? NavigationContainer)?.topViewController as? CollectibleDetailViewController,
                  let toImagePreviewCell = toViewController.currentVisibleMediaCell as? CollectibleMediaImagePreviewCell,
                  let imageViewSnapshot = fromViewController.imageView.snapshotView(afterScreenUpdates: false) else {
                transitionContext.completeTransition(false)
                return
            }

            let containerView = transitionContext.containerView

            imageViewSnapshot.frame = containerView.convert(
                fromViewController.contentView.frame,
                from: fromViewController.view
            )

            containerView.addSubview(imageViewSnapshot)

            toImagePreviewCell.isHidden = true

            let duration = transitionDuration(using: transitionContext)
            let animator = UIViewPropertyAnimator(
                duration: duration,
                curve: .easeInOut
            ) {
                imageViewSnapshot.frame = containerView.convert(
                    toImagePreviewCell.contextView.imageView.frame,
                    from: toImagePreviewCell
                )
                
                fromViewController.view.alpha = 0
            }

            fromViewController.contentView.isHidden = true

            animator.addCompletion { position in
                toImagePreviewCell.isHidden = false

                imageViewSnapshot.removeFromSuperview()

                transitionContext.completeTransition(
                    !transitionContext.transitionWasCancelled
                )
            }

            animator.startAnimation()
        }
    }
}
