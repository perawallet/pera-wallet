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
//  DeepLinkRouter.swift

import UIKit

class DeepLinkRouter {

    private weak var rootViewController: RootViewController?
    private let appConfiguration: AppConfiguration

    private var isInitializedFromDeeplink = false

    init(rootViewController: RootViewController?, appConfiguration: AppConfiguration) {
        self.rootViewController = rootViewController
        self.appConfiguration = appConfiguration
    }

    @discardableResult
    private func openLoginScreen(with route: Screen? = nil) -> UIViewController? {
        return rootViewController?.open(
           .choosePassword(mode: .login, flow: nil, route: route),
           by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
       )
    }
}

extension DeepLinkRouter {
    func initializeFlow() {
        if isInitializedFromDeeplink {
            isInitializedFromDeeplink = false
            return
        }

        if !appConfiguration.session.isValid {
            if appConfiguration.session.authenticatedUser != nil {
                if appConfiguration.session.hasPassword() {
                    openLoginScreen()
                } else {
                    rootViewController?.setupTabBarController()
                }
            } else {
                appConfiguration.session.reset(isContactIncluded: false)
                rootViewController?.open(.introduction(flow: .initializeAccount(mode: .none)), by: .launch, animated: false)
            }
        } else {
            rootViewController?.setupTabBarController()
        }
    }
}

extension DeepLinkRouter {
    func handleDeepLinkRouting(for screen: Screen) -> Bool {
        if !appConfiguration.session.isValid {
            isInitializedFromDeeplink = shouldStartDeepLinkRoutingInInvalidSession(for: screen)
        } else {
            isInitializedFromDeeplink = shouldStartDeepLinkRoutingInValidSession(for: screen)
        }

        return isInitializedFromDeeplink
    }

    private func shouldStartDeepLinkRoutingInInvalidSession(for screen: Screen) -> Bool {
        if appConfiguration.session.authenticatedUser != nil {
            if appConfiguration.session.hasPassword() {
                return openLoginScreen(with: screen) != nil
            } else {
                rootViewController?.setupTabBarController(withInitial: screen)
                return true
            }
        } else {
            return rootViewController?.open(.introduction(flow: .initializeAccount(mode: .none)), by: .launch, animated: false) != nil
        }
    }

    private func shouldStartDeepLinkRoutingInValidSession(for screen: Screen) -> Bool {
        switch screen {
        case .addContact,
             .sendAlgosTransactionPreview,
             .assetSupport,
             .sendAssetTransactionPreview:
            rootViewController?.tabBarViewController.route = screen
            rootViewController?.tabBarViewController.routeForDeeplink()
            return true
        default:
            break
        }

        return false
    }
}

extension DeepLinkRouter {
    func openAsset(from notification: NotificationDetail, for account: String) {
        if !appConfiguration.session.isValid {
            isInitializedFromDeeplink = true
            openAssetFromInvalidSesion(from: notification, for: account)
        } else {
            openAssetFromValidSesion(from: notification, for: account)
        }
    }

    private func openAssetFromInvalidSesion(from notification: NotificationDetail, for address: String) {
        if appConfiguration.session.authenticatedUser != nil {
            if appConfiguration.session.hasPassword() {
                openLoginScreen(with: getRoute(from: notification, for: address))
            } else {
                rootViewController?.setupTabBarController(withInitial: getRoute(from: notification, for: address))
            }
        } else {
            rootViewController?.open(.introduction(flow: .initializeAccount(mode: .none)), by: .launch, animated: false)
        }
    }

    private func getRoute(from notification: NotificationDetail, for address: String) -> Screen {
        if let notificationtype = notification.notificationType,
            notificationtype == .assetSupportRequest {
            return .assetActionConfirmationNotification(address: address, assetId: notification.asset?.id)
        } else {
            return .assetDetailNotification(address: address, assetId: notification.asset?.id)
        }
    }

    private func openAssetFromValidSesion(from notification: NotificationDetail, for address: String) {
        guard let account = appConfiguration.session.account(from: address) else {
            return
        }

        if let notificationtype = notification.notificationType,
           let assetId = notification.asset?.id,
           notificationtype == .assetSupportRequest {
            openAssetSupportRequest(for: account, with: assetId)
            return
        } else {
            openAssetDetail(for: account, with: getAssetDetail(from: notification, for: account))
        }
    }

    private func openAssetSupportRequest(for account: Account, with assetId: Int64) {
        let draft = AssetAlertDraft(
            account: account,
            assetIndex: assetId,
            assetDetail: nil,
            title: "asset-support-add-title".localized,
            detail: String(format: "asset-support-add-message".localized, "\(account.name ?? "")"),
            actionTitle: "title-ok".localized
        )

        rootViewController?.tabBarViewController.route = .assetActionConfirmation(assetAlertDraft: draft)
        rootViewController?.tabBarViewController.routeForDeeplink()
    }

    private func getAssetDetail(from notification: NotificationDetail, for account: Account) -> AssetDetail? {
        var assetDetail: AssetDetail?

        if let assetId = notification.asset?.id {
            assetDetail = account.assetDetails.first { $0.id == assetId }
        }

        return assetDetail
    }

    private func openAssetDetail(for account: Account, with assetDetail: AssetDetail?) {
        rootViewController?.tabBarContainer?.selectedItem = rootViewController?.tabBarContainer?.items[0]
        rootViewController?.tabBarViewController.route = .assetDetail(account: account, assetDetail: assetDetail)
        rootViewController?.tabBarViewController.routeForDeeplink()
    }
}
