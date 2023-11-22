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
//  BaseViewController.swift

import Foundation
import MacaroonUIKit
import UIKit

class BaseViewController:
    UIViewController,
    StatusBarConfigurable,
    TabBarConfigurable,
    UIAdaptivePresentationControllerDelegate {
    var analyticsScreen: ALGAnalyticsScreen? {
        return nil
    }

    var isStatusBarHidden = false
    var hidesStatusBarWhenAppeared = false
    var hidesStatusBarWhenPresented = false

    var hidesCloseBarButtonItem = false
    var leftBarButtonItems: [BarButtonItemRef] = []
    var rightBarButtonItems: [BarButtonItemRef] = []
    
    var tabBarHidden = true
    var tabBarSnapshot: UIView?
    
    private(set) var isViewFirstLoaded = true
    private(set) var isViewAppearing = false
    private(set) var isViewFirstAppeared = true
    private(set) var isViewAppeared = false
    private(set) var isViewDisappearing = false
    private(set) var isViewDisappeared = false
    
    var shouldShowNavigationBar: Bool {
        return true
    }
    var prefersLargeTitle: Bool {
        return false
    }

    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return determinePreferredStatusBarStyle(for: api?.network ?? .mainnet)
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return isStatusBarHidden ? .fade : .none
    }

    let configuration: ViewControllerConfiguration

    init(
        configuration: ViewControllerConfiguration
    ) {
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)

        configureNavigationBarAppearance()
        customizeTabBarAppearence()
        beginTracking()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        endTracking()
    }

    func customizeTabBarAppearence() {}

    func configureNavigationBarAppearance() {}

    func beginTracking() {}

    func endTracking() {
        NotificationCenter.unobserve(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setNeedsNavigationBarAppearanceUpdate()
        linkInteractors()
        setListeners()
        configureAppearance()
        prepareLayout()
        bindData()
    }

    func configureAppearance() {}

    func linkInteractors() {}

    func setListeners() {}

    func prepareLayout() {}

    func bindData() {}

    func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarLayoutUpdateWhenAppearing()
        setNeedsNavigationBarAppearanceUpdateWhenAppearing()
        customizeNavigationBarTitle()
        
        /// <todo>:
        /// Causes to navigation bar title flashing when cancelling back swipe
        setNeedsTabBarAppearanceUpdateOnAppearing(animated: true)

        isViewDisappearing = false
        isViewDisappeared = false
        isViewAppearing = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setNeedsTabBarAppearanceUpdateOnAppeared()

        if let screen = analyticsScreen {
            analytics.track(screen)
        }
        
        isViewAppearing = false
        isViewAppeared = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        setNeedsStatusBarLayoutUpdateWhenDisappearing()

        isViewFirstLoaded = false
        isViewFirstAppeared = false
        isViewAppeared = false
        isViewDisappearing = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        setNeedsTabBarAppearanceUpdateOnDisappeared()

        isViewDisappearing = false
        isViewDisappeared = true
    }

    /// <note> To be able to use this method, the screen should be the delegate of the presentation
    /// controller of presented screen. If it is contained in a navigation controller,
    /// controller?.navigationController?.presentationController?.delegate = ...
    func viewDidAppearAfterInteractiveDismiss() {
        isViewFirstAppeared = false

        if let parentScreen = parent as? BaseViewController {
            parentScreen.viewDidAppearAfterInteractiveDismiss()
        }
    }

    private func setNeedsNavigationBarAppearanceUpdateWhenAppearing() {
        navigationController?.setNavigationBarHidden(!shouldShowNavigationBar, animated: true)
    }

    func didTapBackBarButton() -> Bool {
        return true
    }

    func didTapDismissBarButton() -> Bool {
        return true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            preferredUserInterfaceStyleDidChange(to: traitCollection.userInterfaceStyle)
        }
    }
}

/// <mark>
/// UIAdaptivePresentationControllerDelegate
extension BaseViewController {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewDidAppearAfterInteractiveDismiss()
    }
}

extension BaseViewController {
    private func customizeNavigationBarTitle() {
        guard shouldShowNavigationBar else { return }

        if prefersLargeTitle {
            navigationItem.largeTitleDisplayMode = .always
            let navigationBar = navigationController?.navigationBar
            navigationBar?.prefersLargeTitles = true
            navigationBar?.layoutMargins.left = 24
            navigationBar?.layoutMargins.right = 24
        } else {
            navigationItem.largeTitleDisplayMode =  .never
        }
    }
}

extension BaseViewController {
    var target: ALGAppTarget {
        return ALGAppTarget.current
    }
    
    var session: Session? {
        return configuration.session
    }

    var api: ALGAPI? {
        return configuration.api
    }

    var walletConnector: WalletConnectV1Protocol {
        return configuration.walletConnector
    }

    var loadingController: LoadingController? {
        return configuration.loadingController
    }

    var bannerController: BannerController? {
        return configuration.bannerController
    }
    
    var toastPresentationController: ToastPresentationController? {
        return configuration.toastPresentationController
    }

    var sharedDataController: SharedDataController {
        return configuration.sharedDataController
    }

    var lastSeenNotificationController: LastSeenNotificationController? {
        return configuration.lastSeenNotificationController
    }

    var analytics: ALGAnalytics {
        return configuration.analytics
    }

    var launchController: AppLaunchController {
        return configuration.launchController
    }
    
    var peraConnect: PeraConnect {
        return configuration.peraConnect
    }
}

extension BaseViewController: NavigationBarConfigurable {
    typealias BarButtonItemRef = ALGBarButtonItem
}
