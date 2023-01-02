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
//  NavigationBarConfigurable.swift

import Foundation
import UIKit

protocol NavigationBarConfigurable: AnyObject {
    associatedtype BarButtonItemRef: BarButtonItem
    
    /// Back/Dismiss bar button items should not be added into leftBarButtonItems&rightBarButtonItems.
    /// They will be inserted automatically when setNeedsNavigationBarAppearanceUpdate() is called.
    var leftBarButtonItems: [BarButtonItemRef] { get set }
    var rightBarButtonItems: [BarButtonItemRef] { get set }
    /// Return true if pop/dismiss should be hidden.
    var hidesCloseBarButtonItem: Bool { get }

    func setNeedsNavigationBarAppearanceUpdate()
    
    /// Return true if pop/dismiss should be performed.
    func didTapBackBarButton() -> Bool
    func didTapDismissBarButton() -> Bool
}

extension NavigationBarConfigurable where Self: UIViewController {
    
    var hidesCloseBarButtonItem: Bool {
        return false
    }

    func setNeedsNavigationBarAppearanceUpdate() {
        navigationItem.hidesBackButton = hidesCloseBarButtonItem
        
        if !hidesCloseBarButtonItem {
            if canDismiss() {
                if var dismissBarButtonItem = BarButtonItemRef.dismiss() {
                    dismissBarButtonItem.handler = { [unowned self] in
                        if !self.didTapDismissBarButton() {
                            return
                        }
                        self.navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                    leftBarButtonItems.insert(dismissBarButtonItem, at: 0)
                }
            } else if canGoBack() {
                if var backBarButtonItem = BarButtonItemRef.back() {
                    backBarButtonItem.handler = { [unowned self] in
                        if !self.didTapBackBarButton() {
                            return
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                    leftBarButtonItems.insert(backBarButtonItem, at: 0)
                }
            }
        }
        navigationItem.leftBarButtonItems = leftBarButtonItems.map {
            UIBarButtonItem(customView: BarButton(barButtonItem: $0))
        }

        setNeedsRightBarButtonItemsUpdate()
    }

    func setNeedsRightBarButtonItemsUpdate() {
        navigationItem.rightBarButtonItems = rightBarButtonItems.map {
            UIBarButtonItem(customView: BarButton(barButtonItem: $0))
        }
    }
    
    func didTapBackBarButton() -> Bool {
        return true
    }
    
    func didTapDismissBarButton() -> Bool {
        return true
    }
}

extension NavigationBarConfigurable where Self: UIViewController {
    func canDismiss() -> Bool {
        return
            presentingViewController != nil &&
            navigationController != nil &&
            navigationController?.viewControllers.first == self
    }

    func canGoBack() -> Bool {
        return
            navigationController != nil &&
            navigationController?.viewControllers.first != self
    }
}
