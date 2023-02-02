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

//   DiscoverAssetDetailScreen.swift

import Foundation
import WebKit
import MacaroonUtils

final class DiscoverAssetDetailScreen: PeraInAppBrowserScreen, WKScriptMessageHandler {
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(),
        dataStore: swapDataStore,
        analytics: analytics,
        api: api!,
        sharedDataController: sharedDataController,
        loadingController: loadingController!,
        bannerController: bannerController!,
        presentingScreen: self
    )
    private lazy var buyAlgoFlowCoordinator = BuyAlgoFlowCoordinator(
        presentingScreen: self
    )

    private let assetParameters: DiscoverAssetParameters

    /// <todo>
    /// Normally, we shouldn't retain data store or create flow coordinator here but our currenct
    /// routing approach hasn't been refactored yet.
    private let swapDataStore: SwapDataStore

    private var events: [Event] = [.detailAction]

    init(
        assetParameters: DiscoverAssetParameters,
        swapDataStore: SwapDataStore,
        configuration: ViewControllerConfiguration
    ) {
        self.assetParameters = assetParameters
        self.swapDataStore = swapDataStore
        super.init(configuration: configuration, discoverURL: .assetDetail(parameters: assetParameters))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        events.forEach { event in
            contentController.removeScriptMessageHandler(forName: event.rawValue)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        listenEvents()
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = true
    }
}

extension DiscoverAssetDetailScreen {
    enum Event: String {
        case detailAction = "handleTokenDetailActionButtonClick"
    }

    private func listenEvents() {
        events.forEach { event in
            contentController.add(self, name: event.rawValue)
        }
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard let jsonString = message.body as? String,
              let jsonData = jsonString.data(using: .utf8) else {
            return
        }

        let jsonDecoder = JSONDecoder()

        guard let swapParameters = try? jsonDecoder.decode(DiscoverSwapParameters.self, from: jsonData) else {
            return
        }

        sendAnalyticsEvent(with: swapParameters)
        switch swapParameters.action {
        case .buyAlgo:
            launchBuyAlgo()
        default:
            launchSwap(with: swapParameters)
        }
    }

    private func launchBuyAlgo() {
        buyAlgoFlowCoordinator.launch()
    }

    private func launchSwap(with parameters: DiscoverSwapParameters) {
        let draft = SwapAssetFlowDraft()

        if let assetInID = parameters.assetIn {
            draft.assetInID = assetInID
        }

        if let assetOutID = parameters.assetOut {
            draft.assetOutID = assetOutID
        }

        swapAssetFlowCoordinator.updateDraft(draft)
        swapAssetFlowCoordinator.launch()
    }

    /// <note>
    /// ID 0 is for algo, if it's updated we should update the reflects
    /// Maybe it should be a constant within whole app
    private func sendAnalyticsEvent(with parameters: DiscoverSwapParameters) {
        let assetInID = parameters.assetIn
        let assetOutID = parameters.assetOut

        switch parameters.action {
        case .buyAlgo:
            self.analytics.track(.buyAssetFromDiscover(assetOutID: 0, assetInID: nil))
        case .swapFromAlgo:
            self.analytics.track(.sellAssetFromDiscover(assetOutID: assetOutID, assetInID: 0))
        case .swapToAsset:
            guard let assetOutID else { return }
            self.analytics.track(.buyAssetFromDiscover(assetOutID: assetOutID, assetInID: assetInID))
        case .swapFromAsset:
            self.analytics.track(.sellAssetFromDiscover(assetOutID: assetOutID, assetInID: assetInID))
        }
    }
}
