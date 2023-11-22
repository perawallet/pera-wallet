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
//  ViewControllerConfiguration.swift

import Foundation

final class ViewControllerConfiguration {
    let api: ALGAPI?
    var session: Session?
    let sharedDataController: SharedDataController
    let walletConnector: WalletConnectV1Protocol
    let loadingController: LoadingController?
    let bannerController: BannerController?
    let toastPresentationController: ToastPresentationController?
    let lastSeenNotificationController: LastSeenNotificationController?
    let analytics: ALGAnalytics
    let launchController: AppLaunchController
    let peraConnect: PeraConnect
    
    init(
        api: ALGAPI?,
        session: Session?,
        sharedDataController: SharedDataController,
        walletConnector: WalletConnectV1Protocol,
        loadingControlller: LoadingController?,
        bannerController: BannerController?,
        toastPresentationController: ToastPresentationController?,
        lastSeenNotificationController: LastSeenNotificationController?,
        analytics: ALGAnalytics,
        launchController: AppLaunchController,
        peraConnect: PeraConnect
    ) {
        self.api = api
        self.session = session
        self.sharedDataController = sharedDataController
        self.walletConnector = walletConnector
        self.loadingController = loadingControlller
        self.bannerController = bannerController
        self.toastPresentationController = toastPresentationController
        self.lastSeenNotificationController = lastSeenNotificationController
        self.analytics = analytics
        self.launchController = launchController
        self.peraConnect = peraConnect
    }
}
