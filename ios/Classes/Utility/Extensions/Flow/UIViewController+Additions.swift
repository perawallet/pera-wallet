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
//  UIViewController+Additions.swift

import UIKit
import SVProgressHUD
import SafariServices

extension UIViewController {
    var topMostController: UIViewController? {
        if let controller = self as? UINavigationController {
            return controller.topViewController?.topMostController
        }
        if let controller = self as? UISplitViewController {
            return controller.viewControllers.last?.topMostController
        }
        if let controller = self as? TabBarController {
            return controller.selectedItem?.content?.topMostController
        }
        if let controller = presentedViewController {
            return controller.topMostController
        }
        return self
    }
    
    func displaySimpleAlertWith(title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "title-ok".localized, style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    func displaySimpleAlertWith(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "title-ok".localized, style: .default, handler: handler)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    func displayProceedAlertWith(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let proceedAction = UIAlertAction(title: "title-proceed".localized, style: .default, handler: handler)
        alertController.addAction(proceedAction)
        
        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func add(_ child: UIViewController) {
        if child.parent != nil {
            return
        }
        
        addChild(child)
        view.addSubview(child.view)

        child.view.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        child.didMove(toParent: self)
    }

    func removeFromParentController() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension UIViewController {
    @discardableResult
    func addContent(_ content: UIViewController, prepareLayout: (UIView) -> Void) -> UIViewController {
        addChild(content)
        prepareLayout(content.view)
        content.didMove(toParent: self)
        return content
    }

    func removeFromContainer(animated: Bool = false, completion: (() -> Void)? = nil) {
        func remove() {
            willMove(toParent: nil)
            removeFromParent()
            view.removeFromSuperview()
        }
        if !animated {
            remove()
            completion?()
            return
        }
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.view.alpha = 0.0
            },
            completion: { _ in
                remove()
                completion?()
            }
        )
    }
}

extension UIViewController {
    func dismissProgressIfNeeded() {
        if SVProgressHUD.isVisible() {
            SVProgressHUD.dismiss()
        }
    }
}

extension UIViewController {
    var tabBarContainer: TabBarController? {
        var parentContainer = parent

        while parentContainer != nil {
            if let tabBarContainer = parentContainer as? TabBarController {
                return tabBarContainer
            }
            parentContainer = parentContainer?.parent
        }
        return nil
    }
}

extension UIViewController {
    func open(_ url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}

extension UIViewController {
    var isDarkModeDisplay: Bool {
        if #available(iOS 12.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        }
        
        return false
    }
}

extension UIViewController {
    func statusBarStyleForNetwork(isTestNet: Bool) -> UIStatusBarStyle {
        if isTestNet {
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        }

        if isDarkModeDisplay {
            return .lightContent
        } else {
            return .default
        }
    }
}
