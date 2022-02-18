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
//  TabBarItems.swift

import Foundation
import MacaroonTabBarController
import UIKit

struct HomeTabBarItem: TabBarItem {
    let id: String
    let barButtonItem: MacaroonTabBarController.TabBarButtonItem
    let screen: UIViewController?

    init(
        _ screen: UIViewController
    ) {
        self.id = TabBarItemID.home.rawValue
        self.barButtonItem =
            TabBarButtonItem(
                icon: [
                    .normal("tabbar-icon-accounts"),
                    .selected("tabbar-icon-accounts-selected")
                ]
            )
        self.screen = screen
    }
}

struct AlgoStatisticsTabBarItem: TabBarItem {
    let id: String
    let barButtonItem: MacaroonTabBarController.TabBarButtonItem
    let screen: UIViewController?

    init(
        _ screen: UIViewController
    ) {
        self.id = TabBarItemID.algoStatistics.rawValue
        self.barButtonItem =
            TabBarButtonItem(
                icon: [
                    .normal("tabbar-icon-algo-statistics"),
                    .selected("tabbar-icon-algo-statistics-selected")
                ]
            )
        self.screen = screen
    }
}

struct ContactsTabBarItem: TabBarItem {
    let id: String
    let barButtonItem: MacaroonTabBarController.TabBarButtonItem
    let screen: UIViewController?

    init(
        _ screen: UIViewController
    ) {
        self.id = TabBarItemID.contacts.rawValue
        self.barButtonItem =
            TabBarButtonItem(
                icon: [
                    .normal("tabbar-icon-contacts"),
                    .selected("tabbar-icon-contacts-selected")
                ]
            )
        self.screen = screen
    }
}

struct SettingsTabBarItem: TabBarItem {
    let id: String
    let barButtonItem: MacaroonTabBarController.TabBarButtonItem
    let screen: UIViewController?

    init(
        _ screen: UIViewController
    ) {
        self.id = TabBarItemID.settings.rawValue
        self.barButtonItem =
            TabBarButtonItem(
                icon: [
                    .normal("tabbar-icon-settings"),
                    .selected("tabbar-icon-settings-selected")
                ]
            )
        self.screen = screen
    }
}

enum TabBarItemID: String {
    case home
    case algoStatistics
    case contacts
    case settings
}
