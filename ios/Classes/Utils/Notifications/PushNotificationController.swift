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
import MagpieExceptions
import MagpieHipo
import UIKit

final class PushNotificationController {
    var token: String? {
        return deviceRegistrationController.token
    }

    private lazy var deviceRegistrationController = DeviceRegistrationController(
        target: target,
        session: session,
        api: api
    )

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
}

// MARK: Authentication

extension PushNotificationController {
    func requestAuthorization() {
        deviceRegistrationController.requestAuthorization()
    }
    
    func authorizeDevice(with pushToken: String) {
        deviceRegistrationController.authorizeDevice(with: pushToken)
    }
    
    func sendDeviceDetails(
        completion handler: ((HIPNetworkError<HIPAPIError>?) -> Void)? = nil
    ) {
        deviceRegistrationController.sendDeviceDetails(completion: handler)
    }
    
    func unregisterDevice(
        from network: ALGAPI.Network
    ) {
        deviceRegistrationController.unregisterDevice(from: network)
    }
    
    func revokeDevice(
        completion handler: @escaping BoolHandler
    ) {
        deviceRegistrationController.revokeDevice(completion: handler)
    }
}
