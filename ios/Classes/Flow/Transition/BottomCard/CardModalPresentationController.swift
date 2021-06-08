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
//  CardModalPresentationController.swift

import UIKit

class CardModalPresentationController: UIPresentationController {
    typealias Configuration = ModalConfiguration
    
    private(set) var modalSize: ModalSize
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let containerSize = containerBounds.size
        let presentedSize = calculateSizeOfPresentedView(with: containerSize)
        let presentedOrigin = calculateOriginOfPresentedView(with: presentedSize, inParentSize: containerSize)
        
        return CGRect(origin: presentedOrigin, size: presentedSize)
    }
    
    private lazy var chromeView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = Colors.CardModal.background
        return view
    }()
    
    private var containerBounds: CGRect {
        return containerView?.bounds ?? .zero
    }
    
    private var panGestureRecognizer = UIPanGestureRecognizer()
    
    private var initialFrameOfPresentedView: CGRect?
    
    private let config: Configuration
    
    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        config: Configuration,
        modalSize: ModalSize
    ) {
        self.config = config
        self.modalSize = modalSize
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        setAppearances()
        linkInteractors()
    }
    
    override func containerViewWillLayoutSubviews() {
        chromeView.frame = containerBounds
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        chromeView.alpha = 0.0
        chromeView.frame = containerBounds
        containerView?.insertSubview(chromeView, at: 0)
        
        let animations = {
            self.chromeView.alpha = 1.0
        }
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            animations()
            return
        }
        
        coordinator.animate(
            alongsideTransition: { _ in
                animations()
            },
            completion: nil
        )
    }
    
    override func dismissalTransitionWillBegin() {
        let animations = {
            self.chromeView.alpha = 0.0
        }
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            animations()
            return
        }
        
        coordinator.animate(
            alongsideTransition: { _ in
                animations()
            },
            completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if !completed {
            return
        }
        
        chromeView.removeFromSuperview()
    }
    
    override func size(
        forChildContentContainer container: UIContentContainer,
        withParentContainerSize parentSize: CGSize
    ) -> CGSize {
        return calculateSizeOfPresentedView(with: parentSize)
    }
    
    private func setAppearances() {
        presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView?.layer.cornerRadius = 16.0
        presentedView?.layer.masksToBounds = true
        
        if config.dismissMode == .scroll {
            panGestureRecognizer.addTarget(self, action: #selector(draggedView(_:)))
            presentedView?.isUserInteractionEnabled = true
            presentedView?.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    private func linkInteractors() {
        chromeView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(dismissWhenBackgroundTapped(_:)))
        )
    }
    
    @objc
    private func dismissWhenBackgroundTapped(_ recognizer: UITapGestureRecognizer) {
        if config.dismissMode.isCancelled {
            return
        }
        presentedView?.endEditing(true)
        presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func draggedView(_ sender: UIPanGestureRecognizer) {
        guard let view = presentedView else {
            return
        }
        
        let translation = sender.translation(in: view)
        
        if initialFrameOfPresentedView == nil {
           initialFrameOfPresentedView = view.frame
        }
        
        if sender.state == .ended {
            view.endEditing(true)
            initialFrameOfPresentedView = nil
            presentingViewController.dismiss(animated: true, completion: nil)
        } else {
            if let initialHeight = initialFrameOfPresentedView?.size.height, view.frame.height - translation.y > initialHeight {
                return
            }
            
            changeModalSize(to: .custom(CGSize(width: view.frame.width, height: view.frame.height - translation.y)), animated: false)
        }
        
        sender.setTranslation(.zero, in: view)
    }
}

extension CardModalPresentationController {
    func calculateOriginOfPresentedView(with size: CGSize, inParentSize parentSize: CGSize) -> CGPoint {
        switch modalSize {
        case .compressed, .expanded, .half, .custom:
            return CGPoint(x: (parentSize.width - size.width) / 2.0, y: parentSize.height - size.height)
        case .full:
            return CGPoint(x: 0.0, y: 0.0)
        }
    }
    
    func calculateSizeOfPresentedView(with parentSize: CGSize) -> CGSize {
        switch modalSize {
        case .compressed, .expanded:
            let targetSize = modalSize == .compressed ? UIView.layoutFittingCompressedSize : UIView.layoutFittingExpandedSize
            
            guard
                let presentedNavigationController = presentedViewController as? UINavigationController,
                let visiblePresentedViewController = presentedNavigationController.viewControllers.last
                else {
                    return presentedView?.systemLayoutSizeFitting(targetSize) ?? parentSize
            }
            
            let height = visiblePresentedViewController.view.systemLayoutSizeFitting(targetSize).height
            return CGSize(width: parentSize.width, height: height)
        case .half:
            var presentedSize = parentSize
            presentedSize.height = (parentSize.height / 2.0).upper
            return presentedSize
        case .full:
            return parentSize
        case .custom(let size):
            let width = size.width == UIView.noIntrinsicMetric ? parentSize.width : size.width
            let height = size.height == UIView.noIntrinsicMetric ? parentSize.height : size.height
            
            return CGSize(width: width, height: height)
        }
    }
}

extension CardModalPresentationController: ModalPresenterInteractable {
    func changeModalSize(to newModalSize: ModalSize, animated: Bool, then completion: (() -> Void)?) {
        if modalSize == newModalSize {
            completion?()
            return
        }
        
        modalSize = newModalSize
        
        let newPresentedFrame = frameOfPresentedViewInContainerView
        
        if !animated {
            self.presentedView?.frame = newPresentedFrame
            completion?()
            return
        }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: [],
            animations: {
                self.presentedView?.frame = newPresentedFrame
            },
            completion: { _ in
                completion?()
            }
        )
    }
    
    func changeModalSize(to newModalSize: ModalSize, animated: Bool) {
        changeModalSize(to: newModalSize, animated: animated, then: nil)
    }
}

extension Colors {
    fileprivate enum CardModal {
        static let background = color("bottomOverlayBackground")
    }
}
