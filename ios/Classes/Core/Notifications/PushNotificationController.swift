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
//  PushNotificationController.swift

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
    
    private var api: AlgorandAPI
    
    init(api: AlgorandAPI) {
        self.api = api
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
        guard let user = api.session.applicationConfiguration?.authenticatedUser() else {
            return
        }
        
        if let deviceId = user.deviceId {
            updateDevice(with: deviceId, for: user, completion: handler)
        } else {
            registerDevice(for: user, completion: handler)
        }
    }
    
    private func updateDevice(with id: String, for user: User, completion handler: BoolHandler? = nil) {
        let draft = DeviceUpdateDraft(id: id, pushToken: token, accounts: user.accounts.map(\.address))
        api.updateDevice(with: draft) { response in
            switch response {
            case let .success(device):
                self.api.session.authenticatedUser?.setDeviceId(device.id)
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
        let draft = DeviceRegistrationDraft(pushToken: token, accounts: user.accounts.map(\.address))
        api.registerDevice(with: draft) { response in
            switch response {
            case let .success(device):
                self.api.session.authenticatedUser?.setDeviceId(device.id)
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
    
    func revokeDevice() {
        UIApplication.shared.unregisterForRemoteNotifications()
        
        guard let token = token else {
            return
        }
        
        self.token = nil
        
        let draft = DeviceDeletionDraft(pushToken: token)
        api.unregisterDevice(with: draft)
    }
}

// MARK: Foreground

extension PushNotificationController {
    func show(with notificationDetail: NotificationDetail, then handler: EmptyHandler? = nil) {
        guard let notificationType = notificationDetail.notificationType else {
            return
        }
        
        switch notificationType {
        case .transactionSent,
             .assetTransactionSent:
            displaySentNotification(with: notificationDetail, then: handler)
        case .transactionReceived,
             .assetTransactionReceived:
            displayReceivedNotification(with: notificationDetail, then: handler)
        case .transactionFailed,
             .assetTransactionFailed:
            displaySentNotification(with: notificationDetail, isFailed: true, then: handler)
        case .assetSupportSuccess:
            displayAssetSupportSuccessNotification(with: notificationDetail)
        default:
            break
        }
    }
    
    private func displaySentNotification(
        with notificationDetail: NotificationDetail,
        isFailed: Bool = false,
        then handler: EmptyHandler? = nil
    ) {
        guard let receiverAddress = notificationDetail.receiverAddress,
            let senderAddress = notificationDetail.senderAddress,
            let amount = notificationDetail.amount else {
                return
        }
        
        let isAssetTransaction = notificationDetail.asset != nil
        
        let receiverName = api.session.authenticatedUser?.account(address: receiverAddress)?.name ?? receiverAddress
        
        if let senderAccount = api.session.authenticatedUser?.account(address: senderAddress) {
            Contact.fetchAll(entity: Contact.entityName, with: NSPredicate(format: "address = %@", receiverAddress)) { response in
                switch response {
                case let .results(objects: objects):
                    guard let results = objects as? [Contact] else {
                        return
                    }
                    
                    var message: String
                    
                    if isAssetTransaction {
                        let name = notificationDetail.asset?.name ?? ""
                        let code = notificationDetail.asset?.code ?? ""
                        let fractionDecimals = notificationDetail.asset?.fractionDecimals ?? 0
                        let amountText = amount
                            .assetAmount(fromFraction: fractionDecimals)
                            .toFractionStringForLabel(fraction: fractionDecimals) ?? ""
                        message = String(
                            format: isFailed ? "notification-sent-failed".localized : "notification-sent-success".localized,
                            "\(amountText) \(name) (\(code))",
                            senderAccount.name,
                            results.first?.name ?? receiverName
                        )
                    } else {
                        message = String(
                            format: isFailed ? "notification-sent-failed".localized : "notification-sent-success".localized,
                            "\(amount.toAlgos.toAlgosStringForLabel ?? "") Algos",
                            senderAccount.name,
                            results.first?.name ?? receiverName
                        )
                    }
                    NotificationBanner.showInformation(message, completion: handler)
                default:
                    var message: String
                    
                    if isAssetTransaction {
                        let name = notificationDetail.asset?.name ?? ""
                        let code = notificationDetail.asset?.code ?? ""
                        let fractionDecimals = notificationDetail.asset?.fractionDecimals ?? 0
                        let amountText = amount
                            .assetAmount(fromFraction: fractionDecimals)
                            .toFractionStringForLabel(fraction: fractionDecimals) ?? ""
                        message = String(
                            format: isFailed ? "notification-sent-failed".localized : "notification-sent-success".localized,
                            "\(amountText) \(name) (\(code))",
                            senderAccount.name,
                            receiverName
                        )
                    } else {
                        message = String(
                            format: isFailed ? "notification-sent-failed".localized : "notification-sent-success".localized,
                            "\(amount.toAlgos.toAlgosStringForLabel ?? "") Algos",
                            senderAccount.name,
                            receiverName
                        )
                    }
                    NotificationBanner.showInformation(message, completion: handler)
                }
            }
        }
    }
    
    private func displayReceivedNotification(with notificationDetail: NotificationDetail, then handler: EmptyHandler? = nil) {
        guard let receiverAddress = notificationDetail.receiverAddress,
            let senderAddress = notificationDetail.senderAddress,
            let amount = notificationDetail.amount else {
                return
        }
        
        let isAssetTransaction = notificationDetail.asset != nil
        
        let senderName = api.session.authenticatedUser?.account(address: senderAddress)?.name ?? senderAddress
        
        if let receiverAccount = api.session.authenticatedUser?.account(address: receiverAddress) {
            Contact.fetchAll(entity: Contact.entityName, with: NSPredicate(format: "address = %@", senderAddress)) { response in
                switch response {
                case let .results(objects: objects):
                    guard let results = objects as? [Contact] else {
                        return
                    }
                    
                    var message: String
                    
                    if isAssetTransaction {
                        let name = notificationDetail.asset?.name ?? ""
                        let code = notificationDetail.asset?.code ?? ""
                        let fractionDecimals = notificationDetail.asset?.fractionDecimals ?? 0
                        let amountText = amount
                            .assetAmount(fromFraction: fractionDecimals)
                            .toFractionStringForLabel(fraction: fractionDecimals) ?? ""
                        message = String(
                            format: "notification-received".localized,
                            "\(amountText) \(name) (\(code))",
                            receiverAccount.name,
                            results.first?.name ?? senderName
                        )
                    } else {
                        message = String(
                            format: "notification-received".localized,
                            "\(amount.toAlgos.toAlgosStringForLabel ?? "") Algos",
                            receiverAccount.name,
                            results.first?.name ?? senderName
                        )
                    }
                    NotificationBanner.showInformation(message, completion: handler)
                default:
                    var message: String
                    
                    if isAssetTransaction {
                        let name = notificationDetail.asset?.name ?? ""
                        let code = notificationDetail.asset?.code ?? ""
                        let fractionDecimals = notificationDetail.asset?.fractionDecimals ?? 0
                        let amountText = amount
                            .assetAmount(fromFraction: fractionDecimals)
                            .toFractionStringForLabel(fraction: fractionDecimals) ?? ""
                        message = String(
                            format: "notification-received".localized,
                            "\(amountText) \(name) (\(code))",
                            receiverAccount.name,
                            senderName
                        )
                    } else {
                        message = String(
                            format: "notification-received".localized,
                            "\(amount.toAlgos.toAlgosStringForLabel ?? "") Algos",
                            receiverAccount.name,
                            senderName
                        )
                    }
                    NotificationBanner.showInformation(message, completion: handler)
                }
            }
        }
    }
    
    private func displayAssetSupportSuccessNotification(with notificationDetail: NotificationDetail) {
        guard let senderAddress = notificationDetail.senderAddress,
            let asset = notificationDetail.asset else {
            return
        }
        
        Contact.fetchAll(entity: Contact.entityName, with: NSPredicate(format: "address = %@", senderAddress)) { response in
            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }
                
                let name = asset.name ?? ""
                let code = asset.code ?? ""
                let message = String(
                    format: "notification-support-success".localized(
                        params: results.first?.name ?? senderAddress,
                        "\(name) (\(code))"
                    )
                )
                NotificationBanner.showInformation(message)
            default:
                let name = asset.name ?? ""
                let code = asset.code ?? ""
                let message = String(
                    format: "notification-support-success".localized(
                        params: senderAddress,
                        "\(name) (\(code))"
                    )
                )
                NotificationBanner.showInformation(message)
            }
        }
    }
}

// MARK: Storage

extension PushNotificationController {
    enum Persistence {
        static let DefaultsDeviceTokenKey = "DefaultsDeviceTokenKey"
    }
}
