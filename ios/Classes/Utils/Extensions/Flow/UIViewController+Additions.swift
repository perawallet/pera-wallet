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
//  UIViewController+Additions.swift

import UIKit
import SafariServices

extension UIViewController {
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
    @discardableResult
    func open(_ url: URL?) -> SFSafariViewController? {
        guard let vURL = url?.straightened() else {
            return nil
        }
        
        let safariViewController = SFSafariViewController(url: vURL)
        present(safariViewController, animated: true)

        return safariViewController
    }

    public func openInBrowser(
        _ url: URL
    ) {
        guard let vURL = url.straightened() else {
            return
        }

        if !UIApplication.shared.canOpenURL(vURL) {
            return
        }

        UIApplication.shared.open(
            vURL,
            options: [:],
            completionHandler: nil
        )
    }
}

extension UIViewController {
    var isDarkMode: Bool {
        return traitCollection.userInterfaceStyle == .dark
    }
}

extension UIViewController {
    func determinePreferredStatusBarStyle(
        for network: ALGAPI.Network
    ) -> UIStatusBarStyle {
        switch network {
        case .mainnet:
            return isDarkMode ? .lightContent : .default
        case .testnet:
            return .darkContent
        }
    }
}

extension UIViewController {
    func endEditing(
        _ force: Bool = true
    ) {
        view.endEditing(force)
    }
}
