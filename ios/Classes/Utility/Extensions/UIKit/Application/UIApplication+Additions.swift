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
//  UIApplication+Additions.swift

import UIKit

extension UIApplication {
    
    var isActive: Bool {
        return applicationState == .active
    }
    
    var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isPortrait: Bool {
        switch statusBarOrientation {
        case .portrait,
             .portraitUpsideDown:
            return true
        default:
            return false
        }
    }
    
    var isLandscape: Bool {
        switch statusBarOrientation {
        case .landscapeLeft,
             .landscapeRight:
            return true
        default:
            return false
        }
    }
    
    var statusBarView: UIView? {
        if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
    
    var appDelegate: AppDelegate? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        return appDelegate
    }
    
    var firebaseAnalytics: FirebaseAnalytics? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        return appDelegate.firebaseAnalytics
    }
    
    var appConfiguration: AppConfiguration? {
        guard let rootViewController = rootViewController() else {
            return nil
        }
        
        return rootViewController.appConfiguration
    }
    
    var accountManager: AccountManager? {
        return appDelegate?.accountManager
    }
    
    func rootViewController() -> RootViewController? {
        return keyWindow?.rootViewController as? RootViewController
    }
    
    var safeAreaBottom: CGFloat {
        guard let window = UIApplication.shared.keyWindow else {
            return 0.0
        }
        
        return window.safeAreaInsets.bottom
    }
    
    var safeAreaTop: CGFloat {
        guard let window = UIApplication.shared.keyWindow else {
            return 0.0
        }
        
        return window.safeAreaInsets.top
    }
    
    @discardableResult
    func route<T: UIViewController>(
        to screen: Screen,
        from viewController: UIViewController,
        by style: Screen.Transition.Open,
        animated: Bool = true,
        then completion: EmptyHandler? = nil
    ) -> T? {
        
        guard let rootViewController = rootViewController() else {
            return nil
        }
        
        return rootViewController.route(to: screen, from: viewController, by: style, animated: animated, then: completion)
    }
    
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(settingsURL, options: [:])
    }
    
    var deviceInterfaceStyle: UserInterfaceStyle {
        if #available(iOS 12.0, *) {
            switch UIScreen.main.traitCollection.userInterfaceStyle {
            case .dark:
                return .dark
            default:
                return .light
            }
        }
        
        return .light
    }
    
    var isDarkModeDisplay: Bool {
        if #available(iOS 12.0, *) {
            guard let rootViewController = rootViewController() else {
                return false
            }
            
            return rootViewController.traitCollection.userInterfaceStyle == .dark
        }
        
        return false
    }
}
