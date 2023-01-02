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

//   InAppBrowserScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonUtils
import WebKit

class InAppBrowserScreen:
    BaseViewController,
    WKNavigationDelegate,
    NotificationObserver,
    WKUIDelegate {

    var notificationObservations: [NSObjectProtocol] = []

    private(set) lazy var contentController = WKUserContentController()
    
    private(set) lazy var webView: WKWebView = createWebView()
    private(set) lazy var noContentView = InAppBrowserNoContentView(theme.noContent)

    private var sourceURL: URL?

    private var isViewLayoutLoaded = false

    private var lastURL: URL? { webView.url ?? sourceURL }

    private lazy var refreshControl = UIRefreshControl()

    private let theme = InAppBrowserScreenTheme()

    deinit {
        stopObservingNotifications()
    }

    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)

        startObservingNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateInterfaceTheme(self.traitCollection.userInterfaceStyle)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            updateUIForLoading()
            isViewLayoutLoaded = true
        }
    }

    override func setListeners() {
        super.setListeners()

        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
    }

    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        super.preferredUserInterfaceStyleDidChange(to: userInterfaceStyle)
        updateInterfaceTheme(userInterfaceStyle)
    }

    private func createWebView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.userContentController = contentController
        configuration.preferences = WKPreferences()
        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let versionString = "pera_ios_\(version)"
            if let userAgent = webView.value(forKey: "userAgent") as? String {
                webView.customUserAgent = "\(userAgent) \(versionString)"
            } else {
                webView.customUserAgent = versionString
            }
        }

        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.allowsLinkPreview = false
        webView.scrollView.refreshControl = refreshControl

        let selectionString  = """
        var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}textarea,input{user-select:text;-webkit-user-select:text;}';
        var head = document.head || document.getElementsByTagName('head')[0];
        var style = document.createElement('style'); style.type = 'text/css';
        style.appendChild(document.createTextNode(css)); head.appendChild(style);
"""
        let selectionScript = WKUserScript(
            source: selectionString,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        webView.configuration.userContentController.addUserScript(selectionScript)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }

    /// <mark>
    /// WKNavigationDelegate
    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        updateUIForLoading()
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        defer {
            refreshControl.endRefreshing()
        }

        let systemError = error as NSError

        if systemError.code == NSURLErrorCancelled && systemError.domain == NSURLErrorDomain {
            updateUIForURL()
            return
        }
        
        updateUIForError(error)
    }

    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        updateUIForURL()
        refreshControl.endRefreshing()
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        defer {
            refreshControl.endRefreshing()
        }

        let systemError = error as NSError

        if systemError.code == NSURLErrorCancelled && systemError.domain == NSURLErrorDomain {
            updateUIForURL()
            return
        }

        updateUIForError(error)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences,
        decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
    ) {
        guard let requestUrl = navigationAction.request.url else {
            decisionHandler(.cancel, preferences)
            return
        }

        /// Mail Check
        if requestUrl.isMailURL {
            UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
            decisionHandler(.cancel, preferences)
            return
        }

        /// Web Check
        if requestUrl.isWebURL {
            decisionHandler(.allow, preferences)
            return
        }
        
        let deeplinkQR = DeeplinkQR(url: requestUrl)

        guard let walletConnectURL = deeplinkQR.walletConnectUrl() else {
            decisionHandler(.cancel, preferences)
            return
        }

        launchController.receive(deeplinkWithSource: .walletConnectSessionRequest(walletConnectURL))
        decisionHandler(.cancel, preferences)
    }
}

extension InAppBrowserScreen {
    func load(url: URL?) {
        guard let url = url else {
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        webView.load(request)

        sourceURL = url
    }

    @objc
    private func didRefreshList() {
        webView.reload()
    }
}

extension InAppBrowserScreen {
    private func updateInterfaceTheme(_ style: UIUserInterfaceStyle) {
        let theme = style.peraThemeValue
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

extension InAppBrowserScreen {
    private func addUI() {
        addBackground()
        addWebView()
        addNoContent()
    }

    private func updateUIForLoading() {
        let state = InAppBrowserNoContentView.State.loading(theme.loading)
        updateUI(for: state)
    }

    private func updateUIForError(_ error: Error) {
        let viewModel = InAppBrowserErrorViewModel(error: error)
        let state = InAppBrowserNoContentView.State.error(theme.error, viewModel)
        updateUI(for: state)
    }

    private func updateUI(for state: InAppBrowserNoContentView.State) {
        let isNoContentVisible = !noContentView.isHidden

        noContentView.setState(
            state,
            animated: isViewAppeared && isNoContentVisible
        )

        if isNoContentVisible { return }

        updateUI(
            from: webView,
            to: noContentView,
            animated: isViewAppeared
        )
    }

    private func updateUIForURL() {
        let clearNoContent = {
            [weak self] in
            guard let self else { return }

            self.noContentView.setState(
                nil,
                animated: false
            )
        }

        if !webView.isHidden {
            clearNoContent()
            return
        }

        updateUI(
            from: noContentView,
            to: webView,
            animated: isViewAppeared
        ) { isCompleted in
            if !isCompleted { return }
            clearNoContent()
        }
    }

    private typealias UpdateUICompletion = (Bool) -> Void
    private func updateUI(
        from fromView: UIView,
        to toView: UIView,
        animated: Bool,
        completion: UpdateUICompletion? = nil
    ) {
        UIView.transition(
            from: fromView,
            to: toView,
            duration: animated ? 0.3 : 0,
            options: [.transitionCrossDissolve, .showHideTransitionViews],
            completion: completion
        )
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addWebView() {
        webView.isOpaque = false
        webView.backgroundColor = .clear
        /// <note>
        /// The transition state should be maintained manually at the beginning because both views
        /// are being added so it won't be detected that which view is actually visible. It seems
        /// like `isHidden` property is the only way to prevent unnecessary transition.
        webView.isHidden = true

        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addNoContent() {
        view.addSubview(noContentView)
        noContentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        noContentView.startObserving(event: .retry) {
            [unowned self] in
            self.load(url: self.lastURL)
        }
    }
}

extension InAppBrowserScreen {
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

extension InAppBrowserScreen {
    private func startObservingNotifications() {
        startObservingAppLifeCycleNotifications()
        startObservingCurrencyNotification()
    }

    private func startObservingAppLifeCycleNotifications() {
        observeWhenApplicationDidBecomeActive {
            [weak self] _ in
            guard let self else { return }
            self.updateInterfaceTheme(self.traitCollection.userInterfaceStyle)
        }
    }

    private func startObservingCurrencyNotification() {
        observe(notification: CurrencySelectionViewController.didChangePreferredCurrency) {
            [weak self] _ in
            guard let self else { return }
            self.updateCurrency()
        }
    }
}


extension UIUserInterfaceStyle {
    var peraThemeValue: String {
        switch self {
        case .dark:
            return "dark-theme"
        default:
            return "light-theme"
        }
    }
}
