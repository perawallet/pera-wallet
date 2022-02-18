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
//  StatusBarConfigurable.swift

import Foundation
import UIKit

protocol StatusBarConfigurable: AnyObject {
    
    var isStatusBarHidden: Bool { get set }
    
    var hidesStatusBarWhenAppeared: Bool { get set }
    
    var hidesStatusBarWhenPresented: Bool { get set }
}

extension StatusBarConfigurable where Self: UIViewController {
    
    // Should be called in viewWillAppear(:)
    func setNeedsStatusBarLayoutUpdateWhenAppearing() {
        var statusBarHidden = false
        
        if hidesStatusBarWhenPresented,
            presentingViewController != nil {
            statusBarHidden = true
        } else {
            statusBarHidden = hidesStatusBarWhenAppeared
        }
        
        if isStatusBarHidden == statusBarHidden {
            return
        }
        
        isStatusBarHidden = statusBarHidden
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // Should be called in viewWillDisappear(:)
    func setNeedsStatusBarLayoutUpdateWhenDisappearing() {
        var thePresentedViewController = presentedViewController
        
        if let presentedNavigationController = thePresentedViewController as? UINavigationController {
            thePresentedViewController = presentedNavigationController.topViewController
        }
        
        if let viewController = thePresentedViewController as? StatusBarConfigurable,
            (viewController.hidesStatusBarWhenPresented || viewController.hidesStatusBarWhenAppeared) {
            
            isStatusBarHidden = true
        }
    }
}
