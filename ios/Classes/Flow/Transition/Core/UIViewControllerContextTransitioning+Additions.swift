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
//  UIViewControllerContextTransitioning+Additions.swift

import UIKit

extension UIViewControllerContextTransitioning {
    var fromViewController: UIViewController? {
        return viewController(forKey: .from)
    }
    
    var fromPresentableViewController: ModalPresentableViewController? {
        return fromViewController as? ModalPresentableViewController
    }
    
    var toViewController: UIViewController? {
        return viewController(forKey: .to)
    }
    
    var toPresentableViewController: ModalPresentableViewController? {
        return toViewController as? ModalPresentableViewController
    }
    
    var animatedViewController: UIViewController? {
        return isPresenting ? toViewController : fromViewController
    }
    
    var animatedPresentableViewController: ModalPresentableViewController? {
        return animatedViewController as? ModalPresentableViewController
    }
    
    var fromView: UIView? {
        return view(forKey: .from)
    }
    
    var toView: UIView? {
        return view(forKey: .to)
    }
    
    var animatedView: UIView? {
        return isPresenting ? toView : fromView
    }
    
    var isPresenting: Bool {
        return toViewController?.presentingViewController == fromViewController
    }
    
    var initialFrame: CGRect {
        return animatedViewController.map { initialFrame(for: $0) } ?? .zero
    }
    
    var finalFrame: CGRect {
        return animatedViewController.map { finalFrame(for: $0) } ?? .zero
    }
}
