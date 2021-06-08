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
//  UIViewController+Flow.swift

import UIKit

extension UIViewController {
    
    @discardableResult
    func open<T: UIViewController>(
        _ screen: Screen,
        by style: Screen.Transition.Open,
        animated: Bool = true,
        then completion: EmptyHandler? = nil
    ) -> T? {
        
        let viewController = UIApplication.shared.route(to: screen, from: self, by: style, animated: animated, then: completion)
        
        return viewController as? T
    }

    func closeScreen(by style: Screen.Transition.Close, animated: Bool = true, onCompletion completion: EmptyHandler? = nil) {
        switch style {
        case .pop:
            navigationController?.popViewController(animated: animated)
        case .dismiss:
            presentingViewController?.dismiss(animated: animated, completion: {
                completion?()
            })
        }
    }
    
    func dismissScreen() {
        closeScreen(by: .dismiss)
    }
    
    func popScreen() {
        closeScreen(by: .pop)
    }
}
