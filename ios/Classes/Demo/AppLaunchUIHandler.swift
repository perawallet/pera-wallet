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
//   AppLaunchUIHandler.swift

import Foundation
import UIKit

protocol AppLaunchUIHandler: AnyObject {
    func launchUI(
        _ state: AppLaunchUIState
    )
}

enum AppLaunchUIState {
    case authorization /// pin
    case onboarding
    case main(
        completion: (() -> Void)? = nil
    )
    case mainAfterAuthorization(
        presented: UIViewController,
        completion: () -> Void
    )
    case remoteNotification(
        notification: AlgorandNotification,
        screen: DeepLinkParser.Screen? = nil,
        error: DeepLinkParser.Error? = nil
    )
    case deeplink(DeepLinkParser.Screen)
    case walletConnectSessionRequest(WalletConnectSessionCreationPreferences)
    case bottomWarning(BottomWarningViewConfigurator)
}
