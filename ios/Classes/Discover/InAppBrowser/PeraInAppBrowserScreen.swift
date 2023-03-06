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

//   PeraInAppBrowserScreen.swift

import Foundation
import UIKit

/// <note>:
/// PeraInAppBrowserScreen should be used for websites that created by Pera
/// It handles theme changes, some common logics on that websites.
class PeraInAppBrowserScreen<ScriptMessage>: InAppBrowserScreen<ScriptMessage>
where ScriptMessage: InAppBrowserScriptMessage {
    override var userAgent: String? {
        let version: String? = Bundle.main["CFBundleShortVersionString"]
        let versionUserAgent = version.unwrap { "pera_ios_" + $0 }
        let currentUserAgent = webView.value(forKey: "userAgent") as? String
        return [ currentUserAgent, versionUserAgent ].compound(" ")
    }

    private let discoverURL: DiscoverURL

    deinit {
        stopObservingNotifications()
    }

    init(configuration: ViewControllerConfiguration, discoverURL: DiscoverURL) {
        self.discoverURL = discoverURL
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
}

extension PeraInAppBrowserScreen {
    private func generatePeraURL() -> URL? {
        DiscoverURLGenerator.generateUrl(
            discoverUrl: discoverURL,
            theme: traitCollection.userInterfaceStyle,
            session: session
        )
    }

    private func loadPeraURL() {
        let generatedUrl = generatePeraURL()
        load(url: generatedUrl)
    }
}

extension PeraInAppBrowserScreen {
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

extension PeraInAppBrowserScreen {
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
