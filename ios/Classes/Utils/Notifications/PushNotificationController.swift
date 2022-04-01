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
//  PushNotificationController.swift

import Foundation
import UIKit
import UserNotifications

class PushNotificationController: NSObject {
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: Persistence.DefaultsDeviceTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Persistence.DefaultsDeviceTokenKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    private let target: ALGAppTarget
    private let session: Session
    private let api: ALGAPI
    private let bannerController: BannerController?
    
    init(
        target: ALGAppTarget,
        session: Session,
        api: ALGAPI,
        bannerController: BannerController?
    ) {
        self.target = target
        self.session = session
        self.api = api
        self.bannerController = bannerController
    }
}

// MARK: Authentication

extension PushNotificationController {
    func requestAuthorization() {
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { isGranted, _ in
            if !isGranted {
                return
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func authorizeDevice(with pushToken: String) {
        token = pushToken
        sendDeviceDetails()
    }
    
    func sendDeviceDetails(completion handler: BoolHandler? = nil) {
        guard let user = session.authenticatedUser else {
            return
        }
        
        if let deviceId = user.deviceId {
            updateDevice(with: deviceId, for: user, completion: handler)
        } else {
            registerDevice(for: user, completion: handler)
        }
    }
    
    private func updateDevice(with id: String, for user: User, completion handler: BoolHandler? = nil) {
        let draft = DeviceUpdateDraft(id: id, pushToken: token, app: target.app, accounts: user.accounts.map(\.address))
        api.updateDevice(draft) { response in
            switch response {
            case let .success(device):
                self.session.authenticatedUser?.setDeviceId(device.id)
                handler?(true)
            case let .failure(_, algorandError):
                if let errorType = algorandError?.type,
                   errorType == AlgorandError.ErrorType.deviceAlreadyExists.rawValue {
                    self.registerDevice(for: user, completion: handler)
                } else {
                    handler?(false)
                }
            }
        }
    }
    
    private func registerDevice(for user: User, completion handler: BoolHandler? = nil) {
        let draft = DeviceRegistrationDraft(pushToken: token, app: target.app, accounts: user.accounts.map(\.address))
        api.registerDevice(draft) { response in
            switch response {
            case let .success(device):
                self.session.authenticatedUser?.setDeviceId(device.id)
                handler?(true)
            case let .failure(_, algorandError):
                if let errorType = algorandError?.type,
                   errorType == AlgorandError.ErrorType.deviceAlreadyExists.rawValue {
                    self.registerDevice(for: user, completion: handler)
                } else {
                    handler?(false)
                }
            }
        }
    }
    
    func revokeDevice(
        completion handler: @escaping BoolHandler
    ) {
        UIApplication.shared.unregisterForRemoteNotifications()
        if let token = token {
            self.token = nil
            let draft = DeviceDeletionDraft(pushToken: token)
            api.unregisterDevice(draft) { response in
                switch response {
                case .success:
                    handler(true)
                case .failure:
                    handler(false)
                }
            }
            return
        }

        handler(true)
    }
}

// MARK: Foreground

extension PushNotificationController {
    func present(
        notification: AlgorandNotification,
        action handler: EmptyHandler? = nil
    ) {
        guard let notificationDetail = notification.detail else {
            present(idleNotification: notification)
            return
        }

        switch notificationDetail.type {
        case .transactionSent,
             .assetTransactionSent:
            present(
                notificationForSentTransactionsWith: notificationDetail,
                failure: false,
                action: handler
            )
        case .transactionReceived,
             .assetTransactionReceived:
            present(
                notificationForReceivedTransactionWith: notificationDetail,
                action: handler
            )
        case .transactionFailed,
             .assetTransactionFailed:
            present(
                notificationForSentTransactionsWith: notificationDetail,
                failure: true,
                action: handler
            )
        case .assetSupportSuccess:
            present(notificationForSupportedAssetWith: notificationDetail)
        default:
            present(idleNotification: notification)
        }
    }
    
    private func present(
        idleNotification notification: AlgorandNotification
    ) {
        if let alert = notification.alert {
            bannerController?.presentInfoBanner(alert)
        }
    }
    
    private func present(
        notificationForSentTransactionsWith detail: NotificationDetail,
        failure: Bool = false,
        action handler: EmptyHandler? = nil
    ) {
        guard
            let authenticatedUser = session.authenticatedUser,
            let receiverAddress = detail.receiverAddress,
            let senderAddress = detail.senderAddress,
            let senderName = authenticatedUser.account(address: senderAddress)?.name
        else {
            return
        }
        
        Contact.fetchAll(
            entity: Contact.entityName,
            with: NSPredicate(format: "address = %@", receiverAddress)
        ) { [weak self] response in
            guard let self = self else { return }
            
            let receiverAccount = authenticatedUser.account(address: receiverAddress)
            let defaultReceiverName = receiverAccount?.name ?? receiverAddress
            let amount = detail.amount
            
            let receiverName: String
            if case .results(let objects) = response {
                receiverName = (objects as? [Contact])?.first?.name ?? defaultReceiverName
            } else {
                receiverName = defaultReceiverName
            }
            
            let transactionAmountText: String
            if let asset = detail.asset {
                let assetName = asset.name.someString
                let assetCode = asset.code.someString
                let fractionDecimals = asset.fractionDecimals.someInt
                let amountText = amount
                    .assetAmount(fromFraction: fractionDecimals)
                    .toFractionStringForLabel(fraction: fractionDecimals).someString
                transactionAmountText = "\(amountText) \(assetName) (\(assetCode))"
            } else {
                transactionAmountText = "\(amount.toAlgos.toAlgosStringForLabel.someString) Algo"
            }
            
            let format = failure
                ? "notification-sent-failed".localized
                : "notification-sent-success".localized
            let message = String(
                format: format,
                transactionAmountText,
                senderName,
                receiverName
            )
            
            self.bannerController?.presentInfoBanner(
                message,
                handler
            )
        }
    }
    
    private func present(
        notificationForReceivedTransactionWith detail: NotificationDetail,
        action handler: EmptyHandler? = nil
    ) {
        guard
            let authenticatedUser = session.authenticatedUser,
            let senderAddress = detail.senderAddress,
            let receiverAddress = detail.receiverAddress,
            let receiverName = authenticatedUser.account(address: receiverAddress)?.name
        else {
            return
        }
        
        Contact.fetchAll(
            entity: Contact.entityName,
            with: NSPredicate(format: "address = %@", senderAddress)
        ) { [weak self] response in
            guard let self = self else { return }
            
            let senderAccount = authenticatedUser.account(address: senderAddress)
            let defaultSenderName = senderAccount?.name ?? senderAddress
            let amount = detail.amount
            
            let senderName: String
            if case .results(let objects) = response {
                senderName = (objects as? [Contact])?.first?.name ?? defaultSenderName
            } else {
                senderName = defaultSenderName
            }

            let transactionAmountText: String
            if let asset = detail.asset {
                let assetName = asset.name.someString
                let assetCode = asset.code.someString
                let fractionDecimals = asset.fractionDecimals.someInt
                let amountText = amount
                    .assetAmount(fromFraction: fractionDecimals)
                    .toFractionStringForLabel(fraction: fractionDecimals).someString
                transactionAmountText = "\(amountText) \(assetName) (\(assetCode))"
            } else {
                transactionAmountText = "\(amount.toAlgos.toAlgosStringForLabel.someString) Algo"
            }
            
            let message = String(
                format: "notification-received".localized,
                transactionAmountText,
                receiverName,
                senderName
            )

            self.bannerController?.presentInfoBanner(
                message,
                handler
            )
        }
    }
    
    private func present(
        notificationForSupportedAssetWith detail: NotificationDetail
    ) {
        guard
            let senderAddress = detail.senderAddress,
            let asset = detail.asset
        else {
            return
        }
        
        Contact.fetchAll(
            entity: Contact.entityName,
            with: NSPredicate(format: "address = %@", senderAddress)
        ) { [weak self] response in
            guard let self = self else { return }
            
            let assetName = asset.name.someString
            let assetCode = asset.code.someString
            
            let senderName: String
            if case .results(let objects) = response {
                senderName = (objects as? [Contact])?.first?.name ?? senderAddress
            } else {
                senderName = senderAddress
            }
            
            let message = String(
                format: "notification-support-success".localized(
                    params: senderName,
                    "\(assetName) (\(assetCode))"
                )
            )

            self.bannerController?.presentInfoBanner(message)
        }
    }
}

// MARK: Storage

extension PushNotificationController {
    enum Persistence {
        static let DefaultsDeviceTokenKey = "DefaultsDeviceTokenKey"
    }
}
