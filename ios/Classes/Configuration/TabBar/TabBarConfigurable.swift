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
//  TabBarConfigurable.swift

import UIKit

protocol TabBarConfigurable: AnyObject {
    var isTabBarHidden: Bool { get set }
    var tabBarSnapshot: UIView? { get set }
}

extension TabBarConfigurable where Self: UIViewController {
    func setNeedsTabBarAppearanceUpdateOnAppearing(animated: Bool = true) {
        guard let tabBarContainer = tabBarContainer else {
            return
        }
        
        isTabBarHidden.continue(
            isTrue: { tabBarContainer.setTabBarHidden(true, animated: animated) },
            isFalse: updateTabBarAppearanceOnStacked
        )
    }

    func setNeedsTabBarAppearanceUpdateOnAppeared() {
        guard let tabBarContainer = tabBarContainer else {
            return
        }

        if !isTabBarHidden {
            removeTabBarSnapshot()
        }
        tabBarContainer.setTabBarHidden(isTabBarHidden, animated: false)
    }

    func setNeedsTabBarAppearanceUpdateOnDisappeared() {
        if tabBarContainer == nil {
            return
        }
        updateTabBarAppearanceOnPopped()
    }
}

extension TabBarConfigurable where Self: UIViewController {
    private func updateTabBarAppearanceOnStacked() {
        if isTabBarHidden {
            return
        }

        guard let stackedViewControllers = navigationController.unwrapIfPresent(either: { $0.viewControllers }) else {
            return
        }
        
        guard let stackIndex = stackedViewControllers.firstIndex(of: self)
            .unwrapConditionally(
                where: { $0 > stackedViewControllers.startIndex && $0
                    == stackedViewControllers.index(before: stackedViewControllers.endIndex)
                }
            ) // 1 -> Root, 2 -> Popping
        else {
            return
        }
        
        guard let previousViewControllerInStack = stackedViewControllers[stackedViewControllers.index(
            before: stackIndex
        )] as? TabBarConfigurable else {
            return
        }

        if previousViewControllerInStack.isTabBarHidden {
            addTabBarSnaphot()
        }
    }

    private func updateTabBarAppearanceOnPopped() {
        if isTabBarHidden {
            return
        }

        guard let stackedViewControllers = navigationController.unwrapIfPresent(either: { $0.viewControllers }) else {
            return
        }
        
        guard let nextStackIndex = stackedViewControllers.firstIndex(of: self)
            .unwrapIfPresent(either: { stackedViewControllers.index(after: $0) })
            .unwrapConditionally(where: { $0 < stackedViewControllers.endIndex })
        else {
            return
        }
        
        guard let nextViewControllerInStack = stackedViewControllers[nextStackIndex] as? TabBarConfigurable else {
            return
        }

        if nextViewControllerInStack.isTabBarHidden {
            addTabBarSnaphot()
        }
    }

    private func addTabBarSnaphot() {
        if tabBarSnapshot.unwrapConditionally(where: { $0.isDescendant(of: view) }) != nil {
            return
        }

        guard let tabBarContainer = tabBarContainer else {
            return
        }

        let tabBar = tabBarContainer.tabBar

        guard let newTabBarSnaphot = tabBar.snapshotView(afterScreenUpdates: true) else {
            return
        }
        
        if !isDarkModeDisplay {
            newTabBarSnaphot.applyShadow(tabBarShadow)
        }
        
        view.addSubview(newTabBarSnaphot)
        newTabBarSnaphot.frame = CGRect(
            origin: CGPoint(x: 0.0, y: tabBarContainer.view.bounds.height - tabBar.bounds.height),
            size: tabBar.bounds.size
        )
        
        newTabBarSnaphot.updateShadowLayoutWhenViewDidLayoutSubviews()

        tabBarSnapshot = newTabBarSnaphot
    }

    private func removeTabBarSnapshot() {
        tabBarSnapshot?.removeFromSuperview()
        tabBarSnapshot = nil
    }
}
