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
    let walletConnector: WalletConnector
    let loadingController: LoadingController
    let bannerController: BannerController
    let toastPresentationController: ToastPresentationController
    let analytics: ALGAnalytics
    
    init(
        api: ALGAPI,
        session: Session,
        sharedDataController: SharedDataController,
        walletConnector: WalletConnector,
        loadingController: LoadingController,
        bannerController: BannerController,
        toastPresentationController: ToastPresentationController,
        analytics: ALGAnalytics
    ) {
        self.api = api
        self.session = session
        self.sharedDataController = sharedDataController
        self.walletConnector = walletConnector
        self.loadingController = loadingController
        self.bannerController = bannerController
        self.toastPresentationController = toastPresentationController
        self.analytics = analytics
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
            analytics: analytics
        )
        return configuration
    }
    
    func clearAll() {
        self.session.clear(.keychain)
        self.session.clear(.defaults)
    }
}
