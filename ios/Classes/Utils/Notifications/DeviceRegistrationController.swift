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

//   DeviceRegistrationController.swift

import Foundation
import UIKit
import MagpieHipo
import MagpieExceptions

final class DeviceRegistrationController {
    private(set) var token: String? {
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

    init(
        target: ALGAppTarget,
        session: Session,
        api: ALGAPI
    ) {
        self.target = target
        self.session = session
        self.api = api
    }

    func requestAuthorization() {
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

    func sendDeviceDetails(
        completion handler: ((HIPNetworkError<HIPAPIError>?) -> Void)? = nil
    ) {
        guard let user = session.authenticatedUser else {
            return
        }

        if let deviceId = user.getDeviceId(on: api.network) {
            updateDevice(
                with: deviceId,
                for: user,
                completion: handler
            )
        } else {
            registerDevice(
                for: user,
                completion: handler
            )
        }
    }

    func updateDevice(
        with id: String,
        for user: User,
        completion handler: ((HIPNetworkError<HIPAPIError>?) -> Void)? = nil
    ) {
        let draft = DeviceUpdateDraft(
            id: id,
            pushToken: token,
            app: target.app,
            accounts: user.accounts.map(\.address)
        )

        api.updateDevice(draft) { response in
            switch response {
            case let .success(device):
                self.session.authenticatedUser?.setDeviceID(
                    device.id,
                    on: self.api.network
                )
                handler?(nil)
            case let .failure(apiError, apiErrorDetail):
                if let errorType = apiErrorDetail?.type,
                   errorType == APIErrorType.deviceAlreadyExists.rawValue {
                    self.registerDevice(for: user, completion: handler)
                } else {
                    let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                    handler?(error)
                }
            }
        }
    }

    func registerDevice(
        for user: User,
        completion handler: ((HIPNetworkError<HIPAPIError>?) -> Void)? = nil
    ) {
        let draft = DeviceRegistrationDraft(
            pushToken: token,
            app: target.app,
            accounts: user.accounts.map(\.address)
        )

        api.registerDevice(draft) { response in
            switch response {
            case let .success(device):
                self.session.authenticatedUser?.setDeviceID(
                    device.id,
                    on: self.api.network
                )
                handler?(nil)
            case let .failure(apiError, apiErrorDetail):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: apiErrorDetail
                )
                handler?(error)
            }
        }
    }

    func unregisterDevice(from network: ALGAPI.Network) {
        guard
            let user = session.authenticatedUser,
            let id = user.getDeviceId(on: network)
        else {
            return
        }

        let draft = DeviceUpdateDraft(
            id: id,
            pushToken: nil,
            app: target.app,
            accounts: user.accounts.map(\.address)
        )

        api.unregisterDevice(
            draft,
            from: network
        ) { _ in }
    }

    func revokeDevice(completion handler: @escaping BoolHandler) {
        UIApplication.shared.unregisterForRemoteNotifications()

        if let token = token {
            self.token = nil

            let draft = DeviceDeletionDraft(pushToken: token)

            api.revokeDevice(draft) { response in
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

extension DeviceRegistrationController {
    enum Persistence {
        static let DefaultsDeviceTokenKey = "DefaultsDeviceTokenKey"
    }
}
