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

//
//  KeyboardController.swift

import UIKit

protocol KeyboardControllerDataSource: AnyObject {
    
    func firstResponder(for keyboardController: KeyboardController) -> UIView?
    
    func containerView(for keyboardController: KeyboardController) -> UIView
    
    /*
     Bottom inset to specified first responding element in the scroll view.
     */
    func bottomInsetWhenKeyboardPresented(for keyboardController: KeyboardController) -> CGFloat
    
    /*
     Generally, you can return either 0 for view controller with a permanent input accessory view or the bottom inset
     of the safe area of view controller.
     */
    func bottomInsetWhenKeyboardDismissed(for keyboardController: KeyboardController) -> CGFloat
    
    var scrollView: UIScrollView { get }
}

struct Keyboard {
    var height: CGFloat?
    var animationDuration: TimeInterval = 0.25
    var animationCurve: Int = UIView.AnimationCurve.linear.rawValue
}

class KeyboardController {
    
    typealias UserInfo = (height: CGFloat, animationDuration: TimeInterval, animationCurve: Int)
    
    typealias KeyboardNotificationHandler = (UserInfo) -> Void
    
    // These handlers will override the default implementation if they are not nil.
    var notificationHandlerWhenKeyboardShown: KeyboardNotificationHandler?
    var notificationHandlerWhenKeyboardHidden: KeyboardNotificationHandler?
    
    weak var dataSource: KeyboardControllerDataSource?
    
    var isKeyboardVisible: Bool {
        return keyboard.height != nil
    }
    
    fileprivate var keyboard = Keyboard()
    
    // MARK: Initialization
    
    deinit {
        endTracking()
    }
    
    // MARK: Notification
    
    @objc
    private func didReceive(keyboardWillShow notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        guard let kbHeight = notification.keyboardHeight else {
            return
        }
        
        keyboard.height = kbHeight
        keyboard.animationDuration = notification.keyboardAnimationDuration
        keyboard.animationCurve = notification.keyboardAnimationCurve.rawValue
        
        if let handler = notificationHandlerWhenKeyboardShown {
            handler(
                (height: kbHeight,
                 animationDuration: keyboard.animationDuration,
                 animationCurve: keyboard.animationCurve)
            )
        }
        
        updateContentInsetWithKeyboard()
        scrollEditingFieldToVisibleIfNeeded(animated: true)
    }
    
    @objc
    private func didReceive(keyboardWillHide notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        keyboard.height = nil
        
        if let handler = notificationHandlerWhenKeyboardHidden {
            
            handler(
                (height: 0.0,
                 animationDuration: keyboard.animationDuration,
                 animationCurve: keyboard.animationCurve)
            )
        }
        
        updateContentInsetWithoutKeyboard()
    }
}

// MARK: Private
extension KeyboardController {
    
    private func updateContentInsetWithKeyboard() {
        
        guard let kbHeight = keyboard.height,
            let dataSource = dataSource else {
                return
        }
        
        let contentHeightAfterKeyboardAppeared =
            dataSource.scrollView.contentSize.height +
                dataSource.scrollView.contentInset.top +
                    kbHeight
        
        let height = dataSource.scrollView.bounds.height
        let bottomInset = contentHeightAfterKeyboardAppeared > height ? kbHeight : 0.0
        
        var contentInset = dataSource.scrollView.contentInset
        contentInset.bottom = bottomInset + dataSource.bottomInsetWhenKeyboardPresented(for: self)
        
        dataSource.scrollView.contentInset = contentInset
        
        var scrollIndicatorInsets = dataSource.scrollView.verticalScrollIndicatorInsets
        scrollIndicatorInsets.bottom = bottomInset
        
        dataSource.scrollView.scrollIndicatorInsets = scrollIndicatorInsets
    }
    
    private func updateContentInsetWithoutKeyboard() {
        guard let dataSource = dataSource else {
            return
        }
        
        var contentInset = dataSource.scrollView.contentInset
        contentInset.bottom = dataSource.bottomInsetWhenKeyboardDismissed(for: self)
        
        dataSource.scrollView.contentInset = contentInset
        
        var scrollIndicatorInsets = dataSource.scrollView.verticalScrollIndicatorInsets
        scrollIndicatorInsets.bottom = dataSource.bottomInsetWhenKeyboardDismissed(for: self)
        
        dataSource.scrollView.scrollIndicatorInsets = scrollIndicatorInsets
    }
}

// MARK: Public
extension KeyboardController {
    
    func beginTracking() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillShow:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillHide:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    func endTracking() {
        NotificationCenter
            .default
            .removeObserver(self)
    }
    
    func scrollEditingFieldToVisibleIfNeeded(animated: Bool) {
        if !isKeyboardVisible {
            return
        }
        
        guard let dataSource = dataSource,
            let respondingView = dataSource.firstResponder(for: self) else {
                return
        }
        
        updateContentInsetWithKeyboard()
        
        let containerView = dataSource.containerView(for: self)
        
        let editingRect = respondingView.frame
        let editingRectInView = respondingView.superview?.convert(editingRect, to: containerView) ?? .zero
        
        guard var visibleRect = containerView.superview?.bounds else {
            return
        }
        
        visibleRect.size.height -= keyboard.height ?? 0.0
        visibleRect.size.height -= dataSource.bottomInsetWhenKeyboardPresented(for: self)
        
        if visibleRect.contains(editingRectInView) {
            return
        }
        
        var contentOffset = dataSource.scrollView.contentOffset
        
        if editingRectInView.height > visibleRect.height {
            contentOffset.y += editingRectInView.maxY - visibleRect.maxY // Always invisible area down visible rect.
        } else {
            if editingRectInView.maxY > visibleRect.maxY { // Invisible area down visible rect.
                contentOffset.y += editingRectInView.maxY - visibleRect.maxY
            } else if visibleRect.minY > editingRectInView.minY { // Invisible area up visible rect.
                contentOffset.y += editingRectInView.minY - visibleRect.minY
            }
        }
        
        if !animated {
            dataSource.scrollView.contentOffset = contentOffset
            
            return
        }
        
        let duration = keyboard.animationDuration
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: UIView.AnimationOptions(rawValue: UInt(keyboard.animationCurve >> 16)),
            animations: {
                dataSource.scrollView.contentOffset = contentOffset
            }, completion: nil)
    }
}
