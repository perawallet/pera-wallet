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
        guard let orientation = windows.first?.windowScene?.interfaceOrientation else {
            return true
        }

        switch orientation {
        case .portrait,
             .portraitUpsideDown:
            return true
        default:
            return false
        }
    }
    
    var isLandscape: Bool {
        guard let orientation = windows.first?.windowScene?.interfaceOrientation else {
            return false
        }

        switch orientation {
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
    
    var window: UIWindow? {
        return windowScene?.windows.first(where: \.isKeyWindow)
    }

    var windowScene: UIWindowScene? {
        return connectedScenes.first as? UIWindowScene
    }
    
    var appConfiguration: AppConfiguration? {
        guard let rootViewController = rootViewController() else {
            return nil
        }
        
        return rootViewController.appConfiguration
    }
    
    func rootViewController() -> RootViewController? {
        return window?.rootViewController as? RootViewController
    }
    
    var safeAreaBottom: CGFloat {
        return window?.safeAreaInsets.bottom ?? 0
    }
    
    var safeAreaTop: CGFloat {
        return window?.safeAreaInsets.top ?? 0
    }
    
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(settingsURL, options: [:])
    }
    
    var isDarkModeDisplay: Bool {
        guard let rootViewController = rootViewController() else {
            return false
        }
        
        return rootViewController.traitCollection.userInterfaceStyle == .dark
    }

    var authStatus: AppAuthStatus {
        appDelegate?.authStatus() ?? .ready
    }
}
