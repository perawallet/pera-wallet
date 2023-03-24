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

//   DiscoverInAppBrowserScreen.swift

import Foundation
import UIKit
import WebKit

/// @abstract
/// DiscoverInAppBrowserScreen should be used for websites that created by Pera
/// It handles theme changes, some common logics on that websites.
class DiscoverInAppBrowserScreen<ScriptMessage>: InAppBrowserScreen<ScriptMessage>
where ScriptMessage: InAppBrowserScriptMessage {
    override var userAgent: String? {
        let version: String? = Bundle.main["CFBundleShortVersionString"]
        let versionUserAgent = version.unwrap { "pera_ios_" + $0 }
        let currentUserAgent = webView.value(forKey: "userAgent") as? String
        return [ currentUserAgent, versionUserAgent ].compound(" ")
    }

    private let destination: DiscoverDestination

    deinit {
        /// <note>
        /// Super deinit handles else condition.
        if #unavailable(iOS 14) {
            let messages = DiscoverInAppBrowserScriptMessage.allCases
            userContentController.removeScriptMessageHandlers(forMessages: messages)
        }

        stopObservingNotifications()
    }

    init(
        destination: DiscoverDestination,
        configuration: ViewControllerConfiguration
    ) {
        self.destination = destination
        super.init(configuration: configuration)

        startObservingNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateTheme(self.traitCollection.userInterfaceStyle)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPeraURL()
    }

    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        super.preferredUserInterfaceStyleDidChange(to: userInterfaceStyle)
        updateTheme(userInterfaceStyle)
    }

    override func didPullToRefresh() {
        loadPeraURL()
    }

    override func createUserContentController() -> InAppBrowserUserContentController {
        let controller = super.createUserContentController()
        DiscoverInAppBrowserScriptMessage.allCases.forEach {
            controller.add(
                secureScriptMessageHandler: self,
                forMessage: $0
            )
        }
        return controller
    }

    /// <mark>
    /// WKScriptMessageHandler
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        let inAppMessage = DiscoverInAppBrowserScriptMessage(rawValue: message.name)

        switch inAppMessage {
        case .none:
            super.userContentController(
                userContentController,
                didReceive: message
            )
        case .pushNewScreen:
            handleNewScreenAction(message)
        case .requestDeviceID:
            handleDeviceIDRequest(message)
        }
    }
}

extension DiscoverInAppBrowserScreen {
    private func startObservingNotifications() {
        startObservingAppLifeCycleNotifications()
        startObservingCurrencyChanges()
    }

    private func startObservingAppLifeCycleNotifications() {
        observeWhenApplicationDidBecomeActive {
            [weak self] _ in
            guard let self else { return }
            self.updateTheme(self.traitCollection.userInterfaceStyle)
        }
    }

    private func startObservingCurrencyChanges() {
        observe(notification: CurrencySelectionViewController.didChangePreferredCurrency) {
            [weak self] _ in
            guard let self else { return }
            self.updateCurrency()
        }
    }
}

extension DiscoverInAppBrowserScreen {
    private func generatePeraURL() -> URL? {
        DiscoverURLGenerator.generateURL(
            destination: destination,
            theme: traitCollection.userInterfaceStyle,
            session: session
        )
    }

    private func loadPeraURL() {
        let generatedUrl = generatePeraURL()
        load(url: generatedUrl)
    }
}

extension DiscoverInAppBrowserScreen {
    private func updateTheme(_ style: UIUserInterfaceStyle) {
        let theme = style.peraRawValue
        let script = "updateTheme('\(theme)')"
        webView.evaluateJavaScript(script)
    }

    private func updateCurrency() {
        guard let newCurrency = session?.preferredCurrencyID.localValue else {
            return
        }
        let script = "updateCurrency('\(newCurrency)')"
        webView.evaluateJavaScript(script)
    }
}

extension DiscoverInAppBrowserScreen {
    private func handleNewScreenAction(_ message: WKScriptMessage) {
        if !isAcceptable(message) { return }
        guard let jsonString = message.body as? String else { return }
        guard let jsonData = jsonString.data(using: .utf8) else { return }
        guard let params = try? DiscoverGenericParameters.decoded(jsonData) else { return }
        navigateToDiscoverGeneric(params)
    }

    private func navigateToDiscoverGeneric(_ params: DiscoverGenericParameters) {
        open(
            .discoverGeneric(params),
            by: .push
        )
    }

    private func handleDeviceIDRequest(_ message: WKScriptMessage) {
        if !isAcceptable(message) { return }
        guard let deviceIDDetails = makeDeviceIDDetails() else { return }

        let scriptString = "var message = '" + deviceIDDetails + "'; handleMessage(message);"
        self.webView.evaluateJavaScript(scriptString)
    }

    private func makeDeviceIDDetails() -> String? {
        guard let api else { return nil }
        guard let deviceID = session?.authenticatedUser?.getDeviceId(on: api.network) else { return nil }
        return try? DiscoverDeviceIDDetails(deviceId: deviceID).encodedString()
    }

    private func isAcceptable(_ message: WKScriptMessage) -> Bool {
        let frameInfo = message.frameInfo

        if !frameInfo.isMainFrame { return false }
        if frameInfo.request.url.unwrap(where: \.isPeraURL) == nil { return false }

        return true
    }
}

extension UIUserInterfaceStyle {
    var peraRawValue: String {
        switch self {
        case .dark:
            return "dark-theme"
        default:
            return "light-theme"
        }
    }
}

enum DiscoverInAppBrowserScriptMessage:
    String,
    InAppBrowserScriptMessage {
    case pushNewScreen
    case requestDeviceID = "getDeviceId"
}
