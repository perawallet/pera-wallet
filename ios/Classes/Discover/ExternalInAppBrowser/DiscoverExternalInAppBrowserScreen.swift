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

//   DiscoverExternalInAppBrowserScreen.swift

import Foundation
import WebKit
import MacaroonUtils
import MacaroonUIKit

class DiscoverExternalInAppBrowserScreen: InAppBrowserScreen<DiscoverExternalInAppBrowserScriptMessage> {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private(set) lazy var navigationTitleView = DiscoverExternalInAppBrowserNavigationView()

    private(set) lazy var toolbar = UIToolbar(frame: .zero)
    private lazy var homeButton = makeHomeButton()
    private lazy var previousButton = makePreviousButton()
    private lazy var nextButton = makeNextButton()

    private lazy var navigationScript = createNavigationScript()
    private lazy var peraConnectScript = createPeraConnectScript()

    private var isViewLayoutLoaded = false

    private let destination: DiscoverExternalDestination

    init(
        destination: DiscoverExternalDestination,
        configuration: ViewControllerConfiguration
    ) {
        self.destination = destination

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        addNavigation()
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initializeWebView()
        addToolbarActions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty || toolbar.bounds.isEmpty { return }

        if !isViewLayoutLoaded {
            isViewLayoutLoaded = true
            updateWebViewLayout()
        }
    }

    override func createUserContentController() -> InAppBrowserUserContentController {
        let controller = super.createUserContentController()
        /// <note>
        /// App listens this script in order to catch html5 navigation process
        controller.addUserScript(navigationScript)
        controller.addUserScript(peraConnectScript)
        return controller
    }

    override func updateUIForLoading() {
        super.updateUIForLoading()
        updateToolbarActionsForLoading()
    }

    override func updateUIForURL() {
        super.updateUIForURL()

        updateTitle()
        updateToolbarActionsForURL()
    }

    override func updateUIForError(_ error: Error) {
        super.updateUIForError(error)

        updateTitle()
        updateToolbarActionsForError()
    }

    /// <mark>
    /// WKScriptMessageHandler
    override func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        updateTitle()
        updateToolbarNavigationActions()

        let inAppMessage = DiscoverExternalInAppBrowserScriptMessage(rawValue: message.name)

        switch inAppMessage {
        case .none:
            super.userContentController(
                userContentController,
                didReceive: message
            )
        case .peraconnect:
            handlePeraConnectAction(message)
        }
    }

    func updateToolbarActionsForLoading() {
        updateToolbarNavigationActions()
    }

    func updateToolbarActionsForURL() {
        updateToolbarNavigationActions()
    }

    func updateToolbarActionsForError() {
        updateToolbarNavigationActions()
    }

    private func initializeWebView() {
        let generatedURL = DiscoverURLGenerator.generateURL(
            destination: .external(destination),
            theme: traitCollection.userInterfaceStyle,
            session: session
        )
        load(url: generatedURL)
    }

    private func addNavigation() {
        hidesCloseBarButtonItem = true

        navigationTitleView.customize(DiscoverExternalInAppBrowserNavigationViewTheme())

        navigationItem.titleView = navigationTitleView

        addNavigationBarButtonItems()
    }

    private func addNavigationBarButtonItems() {
        self.leftBarButtonItems = [ makeCloseNavigationBarButtonItem() ]
        self.rightBarButtonItems = [ makeReloadBarButtonItem() ]
    }
    
    private func makeCloseNavigationBarButtonItem() -> ALGBarButtonItem {
        return ALGBarButtonItem(kind: .close(Colors.Text.main.uiColor)) {
            [unowned self] in
            self.eventHandler?(.goBack)
        }
    }

    private func makeReloadBarButtonItem() -> ALGBarButtonItem {
        return ALGBarButtonItem(kind: .reload) {
            [unowned self] in
            self.webView.reload()
        }
    }

    private func bindNavigationTitle(with item: WKBackForwardListItem) {
        navigationTitleView.bindData(DiscoverExternalInAppBrowserNavigationViewModel(item, title: webView.title))
    }
    
    private func bindNavigationTitleForCurrentURL() {
        navigationTitleView.bindData(DiscoverExternalInAppBrowserNavigationViewModel(title: webView.title, subtitle: webView.url?.presentationString))
    }
}

extension DiscoverExternalInAppBrowserScreen {
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
function setupPeraConnectObserver(){const e=new MutationObserver(()=>{const t=document.getElementById("pera-wallet-connect-modal-wrapper"),e=document.getElementById("pera-wallet-redirect-modal-wrapper");if(e&&e.remove(),t){const o=t.getElementsByTagName("pera-wallet-connect-modal");let e="";if(o&&o[0]&&o[0].shadowRoot){const a=o[0].shadowRoot.querySelector("pera-wallet-modal-touch-screen-mode").shadowRoot.querySelector("#pera-wallet-connect-modal-touch-screen-mode-launch-pera-wallet-button");alert("LINK_ELEMENT_V1"+a),a&&(e=a.getAttribute("href"))}else{const r=t.getElementsByClassName("pera-wallet-connect-modal-touch-screen-mode__launch-pera-wallet-button");alert("LINK_ELEMENT_V0"+r),r&&(e=r[0].getAttribute("href"))}alert("WC_URI "+e),e&&(window.webkit.messageHandlers.\(DiscoverExternalInAppBrowserScriptMessage.peraconnect.rawValue).postMessage(e),alert("Message sent to App"+e)),t.remove()}});e.disconnect(),e.observe(document.body,{childList:!0,subtree:!0})}setupPeraConnectObserver();
"""

        return WKUserScript(
            source: peraConnectScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
    }
}

extension DiscoverExternalInAppBrowserScreen {
    private func makeHomeButton() -> UIBarButtonItem {
        let button = ALGBarButtonItem(kind: .discoverHome) {
            [unowned self] in
            defer {
                self.updateToolbarNavigationActions()
            }

            if let homePage = self.webView.backForwardList.backList.first {
                self.webView.go(to: homePage)
            }
        }
        return UIBarButtonItem(customView: BarButton(barButtonItem: button))
    }

    private func makePreviousButton() -> UIBarButtonItem {
        let button = ALGBarButtonItem(kind: .discoverPrevious) {
            [unowned self] in
            self.webView.goBack()
            self.updateToolbarNavigationActions()
        }
        return UIBarButtonItem(customView: BarButton(barButtonItem: button))
    }

    private func makeNextButton() -> UIBarButtonItem {
        let button = ALGBarButtonItem(kind: .discoverNext) {
            [unowned self] in
            self.webView.goForward()
            self.updateToolbarNavigationActions()
        }
        return UIBarButtonItem(customView: BarButton(barButtonItem: button))
    }

    private func addToolbarActions() {
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

        toolbar.items = items
    }

    private func updateToolbarNavigationActions() {
        homeButton.isEnabled = webView.canGoBack
        previousButton.isEnabled = webView.canGoBack
        nextButton.isEnabled = webView.canGoForward
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
}

extension DiscoverExternalInAppBrowserScreen {
    private func handlePeraConnectAction(_ message: WKScriptMessage) {
        guard let jsonString = message.body as? String else { return }
        guard let url = URL(string: jsonString) else { return }
        guard let walletConnectURL = DeeplinkQR(url: url).walletConnectUrl() else { return }

        let src: DeeplinkSource = .walletConnectSessionRequestForDiscover(walletConnectURL)
        launchController.receive(deeplinkWithSource: src)
    }
}

enum DiscoverExternalInAppBrowserScriptMessage:
    String,
    InAppBrowserScriptMessage {
    case peraconnect
}
