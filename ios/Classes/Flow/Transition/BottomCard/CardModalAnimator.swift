// Copyright 2019 Algorand, Inc.

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
//  CardModalAnimator.swift

import UIKit

class CardModalAnimator: AnimatorObjectType {
    
    var config: Configuration
    
    required init(config: Configuration) {
        self.config = config
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch config.animationMode {
        case .normal(let duration), .spring(let duration, _, _):
            return duration
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if transitionContext.isPresenting {
            if let toView = transitionContext.toView {
                containerView.addSubview(toView)
            }
        }
        
        let animatingView = transitionContext.animatedView
        let animatingViewController = transitionContext.animatedPresentableViewController
        
        let finalFrame = transitionContext.finalFrame
        
        var initialFrame = finalFrame
        initialFrame.origin.y = containerView.frame.height + finalFrame.height
        
        config.animationMode.animate({
            animatingView?.frame = transitionContext.isPresenting ? finalFrame : initialFrame
            animatingViewController?.alongsideAnimatedTransition()
        },
        before: {
            animatingView?.frame = transitionContext.isPresenting ? initialFrame : finalFrame
            animatingViewController?.beforeAnimatedTransition()
        },
        after: { _ in
            animatingViewController?.afterAnimatedTransition()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
