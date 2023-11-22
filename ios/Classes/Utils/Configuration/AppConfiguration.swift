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
//  AppConfiguration.swift

import Foundation

final class AppConfiguration {
    let api: ALGAPI
    let session: Session
    let sharedDataController: SharedDataController
    let walletConnector: WalletConnectV1Protocol
    let loadingController: LoadingController
    let bannerController: BannerController
    let toastPresentationController: ToastPresentationController
    let lastSeenNotificationController: LastSeenNotificationController
    let analytics: ALGAnalytics
    let launchController: AppLaunchController
    let peraConnect: PeraConnect
    
    init(
        api: ALGAPI,
        session: Session,
        sharedDataController: SharedDataController,
        walletConnector: WalletConnectV1Protocol,
        loadingController: LoadingController,
        bannerController: BannerController,
        toastPresentationController: ToastPresentationController,
        lastSeenNotificationController: LastSeenNotificationController,
        analytics: ALGAnalytics,
        launchController: AppLaunchController,
        peraConnect: PeraConnect
    ) {
        self.api = api
        self.session = session
        self.sharedDataController = sharedDataController
        self.walletConnector = walletConnector
        self.loadingController = loadingController
        self.bannerController = bannerController
        self.toastPresentationController = toastPresentationController
        self.lastSeenNotificationController = lastSeenNotificationController
        self.analytics = analytics
        self.launchController = launchController
        self.peraConnect = peraConnect
    }
    
    func all() -> ViewControllerConfiguration {
        let configuration = ViewControllerConfiguration(
            api: api,
            session: session,
            sharedDataController: sharedDataController,
            walletConnector: walletConnector,
            loadingControlller: loadingController,
            bannerController: bannerController,
            toastPresentationController: toastPresentationController,
            lastSeenNotificationController: lastSeenNotificationController,
            analytics: analytics,
            launchController: launchController,
            peraConnect: peraConnect
        )
        return configuration
    }
    
    func clearAll() {
        self.session.clear(.keychain)
        self.session.clear(.defaults)
    }
}
