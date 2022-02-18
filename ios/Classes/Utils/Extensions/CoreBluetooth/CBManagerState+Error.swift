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
//  CBManagerState+Error.swift

import CoreBluetooth

extension CBManagerState {
    var errorDescription: (title: String?, subtitle: String?) {
        switch self {
        case .poweredOff:
            return ("ble-error-bluetooth-title".localized, "ble-error-fail-ble-connection-power".localized)
        case .unsupported:
            return ("ble-error-unsupported-device-title".localized, "ble-error-fail-ble-connection-unsupported".localized)
        case .unknown:
            return ("ble-error-unsupported-device-title".localized, "ble-error-fail-ble-connection-unsupported".localized)
        case .unauthorized:
            return ("ble-error-search-title".localized, "ble-error-fail-ble-connection-unauthorized".localized)
        case .resetting:
            return ("ble-error-bluetooth-title".localized, "ble-error-fail-ble-connection-resetting".localized)
        default:
            return (nil, nil)
        }
    }
}
