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

//   DiscoverDappDetailScreen.swift

import Foundation
import WebKit
import MacaroonUtils
import MacaroonUIKit

final class DiscoverDappDetailScreen: InAppBrowserScreen {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?
    
    private lazy var favoriteDapps = createFavoriteDapps()
    
    private lazy var navigationTitleView = DiscoverDappDetailNavigationView()

    private lazy var toolbar = UIToolbar(frame: .zero)
    private lazy var homeButton = makeHomeButton()
    private lazy var previousButton = makePreviousButton()
    private lazy var nextButton = makeNextButton()
    private lazy var favoriteButton = MacaroonUIKit.Button()

    private lazy var navigationScript = createNavigationScript()
    private lazy var peraConnectScript = createPeraConnectScript()

    private var isViewLayoutLoaded = false

    private let dappParameters: DiscoverDappParamaters

    private static let navigationScriptKey = "navigation"
    private static let peraConnectScriptKey = "peraconnect"

    init(
        dappParameters: DiscoverDappParamaters,
        configuration: ViewControllerConfiguration
    ) {
        self.dappParameters = dappParameters

        super.init(configuration: configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        contentController.removeScriptMessageHandler(forName: Self.navigationScriptKey)
        contentController.removeScriptMessageHandler(forName: Self.peraConnectScriptKey)
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = true
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        addNavigation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeWebView()
        addNavigationToolbar()
        executeNavigationScript()
        executePeraConnectScript()
        recordAnalyticsEvent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty || toolbar.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            isViewLayoutLoaded = true
            updateWebViewLayout()
        }
    }

    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super.webView(webView, didFinish: navigation)

        updateButtonsStateIfNeeded()
        updateTitle()
        updateFavouriteActionStateForCurrentURL()
    }

    override func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        super.webView(webView, didFail: navigation, withError: error)

        updateButtonsStateIfNeeded()
    }

    override func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        super.webView(webView, didFailProvisionalNavigation: navigation, withError: error)

        updateButtonsStateIfNeeded()
    }

    private func initializeWebView() {
        guard let url = URL(string: dappParameters.url) else {
            return
        }

        let generatedUrl = DiscoverURLGenerator.generateUrl(
            discoverUrl: .other(url: url),
            theme: traitCollection.userInterfaceStyle,
            session: session
        )

        load(url: generatedUrl)
    }

    private func addNavigation() {
        navigationTitleView.customize(DiscoverDappDetailNavigationViewTheme())

        navigationItem.titleView = navigationTitleView

        bindNavigationTitle(with: dappParameters)

        self.rightBarButtonItems = [ ALGBarButtonItem.flexibleSpace() ]
    }

    private func bindNavigationTitle(with item: WKBackForwardListItem) {
        navigationTitleView.bindData(DiscoverDappDetailNavigationViewModel(item, title: webView.title))
    }

    private func bindNavigationTitle(with dappParameters: DiscoverDappParamaters) {
        navigationTitleView.bindData(DiscoverDappDetailNavigationViewModel(dappParameters))
    }
    
    private func bindNavigationTitleForCurrentURL() {
        navigationTitleView.bindData(DiscoverDappDetailNavigationViewModel(title: webView.title, subtitle: webView.url?.presentationString))
    }

    /// <note>
    /// App listens this script in order to catch html5 navigation process
    private func executeNavigationScript() {
        contentController.addUserScript(navigationScript)
        contentController.add(self, name: Self.navigationScriptKey)
    }

    private func executePeraConnectScript() {
        contentController.addUserScript(peraConnectScript)
        contentController.add(self, name: Self.peraConnectScriptKey)
    }
}

extension DiscoverDappDetailScreen {
    private func createNavigationScript() -> WKUserScript {
        let navigationScript = """
!function(t){function e(t){setTimeout((function(){window.webkit.messageHandlers.navigation.postMessage(t)}),0)}function n(n){return function(){return e("other"),n.apply(t,arguments)}}t.pushState=n(t.pushState),t.replaceState=n(t.replaceState),window.addEventListener("popstate",(function(){e("backforward")}))}(window.history);
"""

        return WKUserScript(
            source: navigationScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
    }

    private func createPeraConnectScript() -> WKUserScript {
        let peraConnectScript = """
function setupPeraConnectObserver(){const e=new MutationObserver(()=>{const t=document.getElementById("pera-wallet-connect-modal-wrapper"),e=document.getElementById("pera-wallet-redirect-modal-wrapper");if(e&&e.remove(),t){const o=t.getElementsByTagName("pera-wallet-connect-modal");let e="";if(o&&o[0]&&o[0].shadowRoot){const a=o[0].shadowRoot.querySelector("pera-wallet-modal-touch-screen-mode").shadowRoot.querySelector("#pera-wallet-connect-modal-touch-screen-mode-launch-pera-wallet-button");alert("LINK_ELEMENT_V1"+a),a&&(e=a.getAttribute("href"))}else{const r=t.getElementsByClassName("pera-wallet-connect-modal-touch-screen-mode__launch-pera-wallet-button");alert("LINK_ELEMENT_V0"+r),r&&(e=r[0].getAttribute("href"))}alert("WC_URI "+e),e&&(window.webkit.messageHandlers.\(Self.peraConnectScriptKey).postMessage(e),alert("Message sent to App"+e)),t.remove()}});e.disconnect(),e.observe(document.body,{childList:!0,subtree:!0})}setupPeraConnectObserver();
"""

        return WKUserScript(
            source: peraConnectScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
    }
}

extension DiscoverDappDetailScreen: WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        self.updateButtonsStateIfNeeded()
        self.updateTitle()
        self.routeWalletConnectIfNeeded(with: message)
    }
}

extension DiscoverDappDetailScreen {
    private func makeHomeButton() -> UIBarButtonItem {
        let button = ALGBarButtonItem(kind: .discoverHome) {
            [unowned self] in
            guard let homePage = self.webView.backForwardList.backList.first else {
                self.updateButtonsStateIfNeeded()
                return
            }

            self.webView.go(to: homePage)
            self.updateButtonsStateIfNeeded()
        }
        return UIBarButtonItem(customView: BarButton(barButtonItem: button))
    }

    private func makePreviousButton() -> UIBarButtonItem {
        let button = ALGBarButtonItem(kind: .discoverPrevious) {
            [unowned self] in
            self.webView.goBack()
            self.updateButtonsStateIfNeeded()
        }
        return UIBarButtonItem(customView: BarButton(barButtonItem: button))
    }

    private func makeNextButton() -> UIBarButtonItem {
        let button = ALGBarButtonItem(kind: .discoverNext) {
            [unowned self] in
            self.webView.goForward()
            self.updateButtonsStateIfNeeded()
        }
        return UIBarButtonItem(customView: BarButton(barButtonItem: button))
    }
    
    private func makeFavoriteButton() -> UIBarButtonItem {
        favoriteButton.customizeAppearance([
            .icon([
                .normal("icon-favourite"),
                .selected("icon-favourite-filled"),
            ]),
        ])
        
        favoriteButton.snp.makeConstraints {
            $0.fitToSize((40, 40))
        }
        
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        
        return UIBarButtonItem(customView: favoriteButton)
    }

    private func addNavigationToolbar() {
        view.addSubview(toolbar)
        toolbar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(view.safeAreaBottom)
        }

        var items = [UIBarButtonItem]()

        previousButton.isEnabled = false
        nextButton.isEnabled = false

        items.append( previousButton )
        items.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append( nextButton )
        items.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append( homeButton )
        
        if shouldAllowFavoriteAction() {
            items.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
            items.append(makeFavoriteButton())
        }

        toolbar.items = items

        setToolbarItems(items, animated: true)
        updateButtonsStateIfNeeded()
    }
    
    private func updateWebViewLayout() {
        webView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(view.safeAreaBottom + toolbar.bounds.height)
        }
    }
    
    private func updateTitle() {
        guard let item = webView.backForwardList.currentItem else {
            bindNavigationTitleForCurrentURL()
            return
        }

        bindNavigationTitle(with: item)
    }

    private func updateButtonsStateIfNeeded() {
        let canGoBack = webView.canGoBack
        let canGoForward = webView.canGoForward
        let isHomeEnabled = canGoBack

        homeButton.isEnabled = isHomeEnabled
        previousButton.isEnabled = canGoBack
        nextButton.isEnabled = canGoForward
    }
}

extension DiscoverDappDetailScreen {
    @objc
    private func didTapFavorite() {
        guard let url = createURLToAddFavorites() else {
            return
        }
        
        let dappDetails = DiscoverFavouriteDappDetails(
            name: webView.title,
            url: url
        )
        
        if isFavorite(url) {
            removeFromFavorites(url: url, dapp: dappDetails)
        } else {
            addToFavorites(url: url, dapp: dappDetails)
        }
    }
    
    private func routeWalletConnectIfNeeded(with message: WKScriptMessage) {
        guard message.name == Self.peraConnectScriptKey else { return }

        guard let jsonString = message.body as? String, let url = URL(string: jsonString) else {
            return
        }

        let deeplinkQR = DeeplinkQR(url: url)

        guard let walletConnectURL = deeplinkQR.walletConnectUrl() else {
            return
        }

        launchController.receive(deeplinkWithSource: .walletConnectSessionRequestForDiscover(walletConnectURL))
    }

    private func recordAnalyticsEvent() {
        self.analytics.track(.discoverDappDetail(dappParameters: dappParameters))
    }
}

extension DiscoverDappDetailScreen {
    private func createFavoriteDapps() -> Set<URL> {
        return dappParameters.favorites?.reduce(into: Set<URL>(), {
            guard let url = URL(string: $1.url) else { return }
            $0.insert(url)
        }) ?? []
    }
    
    private func shouldAllowFavoriteAction() -> Bool {
        return dappParameters.favorites != nil
    }
    
    private func createURLToAddFavorites() -> URL? {
        guard let currentUrl = webView.url else {
            return nil
        }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = currentUrl.scheme
        urlComponents.host = currentUrl.host
        
        return urlComponents.url
    }

    private func isFavorite(_ url: URL) -> Bool {
        return favoriteDapps.contains(url)
    }
    
    private func addToFavorites(
        url: URL,
        dapp: DiscoverFavouriteDappDetails
    ) {
        if hasExceededFavouritesLimit() {
            self.bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "discover-error-favorites-max-limit".localized
            )
            return
        }
        
        favoriteDapps.insert(url)
        setFavoriteActionSelected(true)
        eventHandler?(.addToFavorites(dapp))
    }
    
    private func hasExceededFavouritesLimit() -> Bool {
        return favoriteDapps.count >= 50
    }
    
    private func removeFromFavorites(
        url: URL,
        dapp: DiscoverFavouriteDappDetails
    ) {
        favoriteDapps.remove(url)
        setFavoriteActionSelected(false)
        eventHandler?(.removeFromFavorites(dapp))
    }
    
    private func updateFavouriteActionStateForCurrentURL() {
        let url = createURLToAddFavorites()
        updateFavouriteActionState(for: url)
    }
    
    private func updateFavouriteActionState(for url: URL?) {
        let isSelected = url.unwrap(isFavorite) ?? false
        setFavoriteActionSelected(isSelected)
    }
    
    private func setFavoriteActionSelected(_ selected: Bool) {
        favoriteButton.isSelected = selected
    }
}

extension DiscoverDappDetailScreen {
    enum Event {
        case addToFavorites(DiscoverFavouriteDappDetails)
        case removeFromFavorites(DiscoverFavouriteDappDetails)
    }
}
