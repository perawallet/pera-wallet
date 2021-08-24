// Copyright 2019 Algorand, Inc.

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

import UIKit

class BaseViewController: UIViewController, TabBarConfigurable, AnalyticsScreen {
    var isTabBarHidden = true
    var tabBarSnapshot: UIView?
    
    var isStatusBarHidden: Bool = false
    var hidesStatusBarWhenAppeared: Bool = false
    var hidesStatusBarWhenPresented: Bool = false
    
    var name: AnalyticsScreenName? {
        return nil
    }
    
    var params: AnalyticsParameters? {
        return nil
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyleForNetwork(isTestNet: api?.isTestNet ?? false )
    }
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return isStatusBarHidden ? .fade : .none
    }
    
    var leftBarButtonItems: [BarButtonItemRef] = []
    var rightBarButtonItems: [BarButtonItemRef] = []
    
    var hidesCloseBarButtonItem: Bool {
        return false
    }
    
    var shouldShowNavigationBar: Bool {
        return true
    }
    
    private(set) var isViewFirstLoaded = true
    private(set) var isViewAppearing = false
    private(set) var isViewAppeared = false
    private(set) var isViewDisappearing = false
    private(set) var isViewDisappeared = false
    
    let configuration: ViewControllerConfiguration
    
    init(configuration: ViewControllerConfiguration) {
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
    
    func customizeTabBarAppearence() { }
    
    func configureNavigationBarAppearance() {
    }
    
    func beginTracking() { }

    func endTracking() {
        NotificationCenter.unobserve(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPrimaryBackgroundColor()
        setNeedsNavigationBarAppearanceUpdate()
        linkInteractors()
        setListeners()
        configureAppearance()
        prepareLayout()
        bindData()
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.font(withWeight: .semiBold(size: 16.0)),
            NSAttributedString.Key.foregroundColor: Colors.Text.primary
        ]
    }
    
    func configureAppearance() {
        view.backgroundColor = Colors.Background.primary
    }

    func linkInteractors() {
    }
    
    func setListeners() {
    }

    func prepareLayout() {
    }
    
    func bindData() {
    }
    
    @available(iOS 12.0, *)
    func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarLayoutUpdateWhenAppearing()
        setNeedsNavigationBarAppearanceUpdateWhenAppearing()
        setNeedsTabBarAppearanceUpdateOnAppearing()
        
        isViewDisappeared = false
        isViewAppearing = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsTabBarAppearanceUpdateOnAppeared()
        track(self)
        isViewAppearing = false
        isViewAppeared = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNeedsStatusBarLayoutUpdateWhenDisappearing()
        
        isViewFirstLoaded = false
        isViewAppeared = false
        isViewDisappearing = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setNeedsTabBarAppearanceUpdateOnDisappeared()
        isViewDisappearing = false
        isViewDisappeared = true
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

        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                preferredUserInterfaceStyleDidChange(to: traitCollection.userInterfaceStyle)
            }
        }
    }
}

extension BaseViewController {
    func setPrimaryBackgroundColor() {
        navigationController?.navigationBar.barTintColor = Colors.Background.primary
        navigationController?.navigationBar.tintColor = Colors.Background.primary
    }
    
    func setSecondaryBackgroundColor() {
        navigationController?.navigationBar.barTintColor = Colors.Background.secondary
        navigationController?.navigationBar.tintColor = Colors.Background.secondary
    }
    
    func setTertiaryBackgroundColor() {
        navigationController?.navigationBar.barTintColor = Colors.Background.tertiary
        navigationController?.navigationBar.tintColor = Colors.Background.tertiary
    }
}

extension BaseViewController: StatusBarConfigurable {
}

extension BaseViewController {
    var session: Session? {
        return configuration.session
    }
    
    var api: AlgorandAPI? {
        return configuration.api
    }

    var walletConnector: WalletConnector {
        return configuration.walletConnector
    }
}

extension BaseViewController: NavigationBarConfigurable {
    typealias BarButtonItemRef = ALGBarButtonItem
}
