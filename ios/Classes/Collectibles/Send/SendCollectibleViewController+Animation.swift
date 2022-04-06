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

//   SendCollectibleViewController+Animation.swift

import Foundation
import UIKit

extension SendCollectibleViewController {
    func handleActionViewHeightChange(
        _ actionViewNewHeight: CGFloat
    ) {
        let isKeyboardHidden = keyboardHeight == 0

        guard isKeyboardHidden else {
            return
        }

        /// <note>
        /// When text is deleted, resize image to its initial size if needed.
        if sendCollectibleActionView.initialHeight == actionViewNewHeight {
            updateImageBeforeAnimations(for: .initial)
            animateImageLayout(imageView)
            return
        }

        /// <note>
        /// If text is changed but keyboard isn't used we get the diff between `actionViewNewHeight` and `sendCollectibleActionView.initialHeight`. If diff is different than initial height, we substract the diff from the image size then apply the animations.
        if sendCollectibleActionView.isEditing {
            actionViewHeightDiff = actionViewNewHeight - sendCollectibleActionView.initialHeight

            if actionViewHeightDiff != 0 {
                let imageHorizontalPaddings = 2 * theme.horizontalPadding
                let initialImageHeight = sendCollectibleView.contextViewContainer.frame.width - imageHorizontalPaddings

                let imageMaxHeight = initialImageHeight
                let imageViewHeight = max(
                    theme.imageMinHeight,
                    imageMaxHeight - actionViewHeightDiff
                )

                updateImageBeforeAnimations(
                    for: .custom(height: imageViewHeight)
                )

                animateImageLayout(imageView)
            }
        }
    }
}

extension SendCollectibleViewController {
    func handleScrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        let contentY = scrollView.contentOffset.y + scrollView.contentInset.top

        let imageHorizontalPaddings = 2 * theme.horizontalPadding
        let initialImageHeight = sendCollectibleView.contextViewContainer.frame.width - imageHorizontalPaddings

        var imageViewMaxHeight = initialImageHeight

        if keyboardHeight == 0 {
            imageViewMaxHeight -= actionViewHeightDiff
        }

        let calculatedHeight = imageViewMaxHeight - contentY

        var imageViewHeight = max(
            theme.imageMinHeight,
            theme.imageMinHeight * calculatedHeight / imageViewMaxHeight
        )

        if contentY == 0 {
            imageViewHeight = imageViewMaxHeight
        }

        updateImageBeforeAnimations(for: .custom(height: imageViewHeight))
        animateContentLayout(view)
    }
}

extension SendCollectibleViewController {
    func animateContentLayout(
        _ view: UIView,
        completion: EmptyHandler? = nil
    ) {
        let property = UIViewPropertyAnimator(
            duration: 0.5,
            dampingRatio: 0.8
        ) {
            view.layoutIfNeeded()
        }
        property.addCompletion { _ in
            completion?()
        }
        property.startAnimation()
    }

    func animateImageLayout(
        _ view: UIView
    ) {
        let animator = UIViewPropertyAnimator(
            duration: 0.5,
            curve: .easeInOut
        ) {
            view.layoutIfNeeded()
        }

        animator.startAnimation()
    }

    func animateBottomSheetLayout() {
        sendCollectibleActionView.updateContentBeforeAnimations(for: .end)

        let animator = UIViewPropertyAnimator(
            duration: 0.5,
            dampingRatio: 0.8
        ) {
            [unowned self] in

            updateAlongsideAnimations(for: .end)
            view.layoutIfNeeded()
        }

        animator.startAnimation()
    }
}
