// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WebImportSuccessScreen.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WebImportSuccessScreen: BaseViewController {
    typealias EventHandler = (Event, WebImportSuccessScreen) -> Void

    var eventHandler: EventHandler?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private var footerBackgroundEffect: Effect? {
        get { footerBackgroundView.effect }
        set { footerBackgroundView.effect = newValue }
    }

    private lazy var footerView: UIView = .init()
    private lazy var footerBackgroundView = EffectView()

    private lazy var theme = WebImportSuccessScreenTheme()
    private lazy var listView = createListView()

    private lazy var listLayout = WebImportSuccessScreenListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = WebImportSuccessScreenDataSource(listView, dataController: dataController)

    private lazy var goToHomeActionView = MacaroonUIKit.Button()

    private let dataController: WebImportSuccessScreenDataController

    init(
        dataController: WebImportSuccessScreenDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.customizeAppearance(theme.listView)
    }

    override func setListeners() {
        listView.dataSource = listDataSource
        listView.delegate = listLayout
    }

    override func prepareLayout() {
        addList()
        addFooter()
        addGoToHomeActionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.listDataSource.reload(snapshot)
            }
        }
        dataController.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if footerView.bounds.isEmpty {
            return
        }

        updateScrollLayoutWhenViewDidLayoutSubviews()
        updateLayoutOnScroll()
    }

    private func updateLayoutOnScroll() {
        if footerView.bounds.isEmpty {
            return
        }

        let endOfContent = view.frame.maxY - listView.contentOffset.y
        let hidesFooterBackgroundEffect = endOfContent <= footerBackgroundView.frame.minY
        footerBackgroundView.setEffectHidden(hidesFooterBackgroundEffect)
    }

    private func updateScrollLayoutWhenViewDidLayoutSubviews() {
        if !footerView.bounds.isEmpty {
            listView.setContentInset(top: 0)
            listView.setContentInset(bottom: footerView.bounds.height)
        }
    }
}

extension WebImportSuccessScreen {
    private func createListView() -> UICollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.listMinimumLineSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.customizeAppearance(theme.listView)
        collectionView.contentInset.top = theme.listContentInsetTop
        return collectionView
    }

    private func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addFooter() {
        view.addSubview(footerBackgroundView)
        footerBackgroundView.snp.makeConstraints {
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        footerBackgroundView.addSubview(footerView)
        footerView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == footerBackgroundView.safeAreaBottom
            $0.trailing == 0
        }

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }

    private func addGoToHomeActionView() {
        goToHomeActionView.customizeAppearance(theme.goToHomeAction)

        footerView.addSubview(goToHomeActionView)
        goToHomeActionView.contentEdgeInsets = theme.goToHomeActionContentEdgeInsets
        goToHomeActionView.snp.makeConstraints {
            $0.top == theme.goToHomeActionEdgeInsets.top
            $0.leading == theme.goToHomeActionEdgeInsets.leading
            $0.bottom == theme.goToHomeActionEdgeInsets.bottom
            $0.trailing == theme.goToHomeActionEdgeInsets.trailing
        }

        goToHomeActionView.addTouch(
            target: self,
            action: #selector(performGoToHomeAction)
        )
    }

    @objc
    private func performGoToHomeAction() {
        eventHandler?(.didGoToHome, self)
    }
}

extension WebImportSuccessScreen {
    enum Event {
        case didGoToHome
    }
}
