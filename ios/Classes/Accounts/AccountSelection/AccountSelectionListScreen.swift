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

//   AccountSelectionListScreen.swift

import UIKit
import MacaroonUIKit

final class AccountSelectionListScreen<DataController: AccountSelectionListDataController>:
    BaseViewController,
    NavigationBarLargeTitleConfigurable,
    UICollectionViewDelegateFlowLayout  {
    var navigationBarScrollView: UIScrollView {
        return listView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private(set) lazy var navigationBarLargeTitleController = NavigationBarLargeTitleController(screen: self)
    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = createNavigationBarLargeTitleView()

    private var isLayoutFinalized = false

    private let navigationBarTitle: String
    private let listView: UICollectionView
    private let dataController: DataController
    private let listLayout: AccountSelectionListLayout

    typealias DataSource = UICollectionViewDiffableDataSource<DataController.SectionIdentifierType, DataController.ItemIdentifierType>
    private let listDataSource: DataSource

    private let theme: AccountSelectionListScreenTheme

    typealias EventHandler = (Event, AccountSelectionListScreen) -> Void
    private let eventHandler: EventHandler

    init(
        navigationBarTitle: String,
        listView: UICollectionView,
        dataController: DataController,
        listLayout: AccountSelectionListLayout,
        listDataSource: DataSource,
        theme: AccountSelectionListScreenTheme,
        eventHandler: @escaping EventHandler,
        configuration: ViewControllerConfiguration
    ) {
        self.navigationBarTitle = navigationBarTitle
        self.listView = listView
        self.dataController = dataController
        self.listLayout = listLayout
        self.listDataSource = listDataSource
        self.eventHandler = eventHandler
        self.theme = theme

        super.init(configuration: configuration)
    }

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case .didUpdate(let snapshot):
                self.listDataSource.apply(
                    snapshot,
                    animatingDifferences: false
                )
            }
        }

        dataController.load()
    }

    override func setListeners() {
        super.setListeners()

        navigationBarLargeTitleController.activate()

        listView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()

        addUI()
    }

    override func bindData() {
        super.bindData()

        navigationBarLargeTitleController.title = navigationBarTitle
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isLayoutFinalized ||
           navigationBarLargeTitleView.bounds.isEmpty {
            return
        }

        updateUIWhenViewDidLayout()

        isLayoutFinalized = true
    }

    private func addUI() {
        addBackground()
        addNavigationBarLargeTitle()
        addList()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let account = dataController[indexPath] else {
            assertionFailure("Account at index path is nil.")
            return
        }

        eventHandler(.didSelect(account), self)
    }

    /// <todo> Refactor
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let loadingCell = cell as? AccountSelectionListLoadingAccountItemCell
        loadingCell?.startAnimating()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let loadingCell = cell as? AccountSelectionListLoadingAccountItemCell
        loadingCell?.stopAnimating()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            referenceSizeForHeaderInSection: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

extension AccountSelectionListScreen {
    private func updateUIWhenViewDidLayout() {
        updateListContentInsetsWhenViewDidLayout()
    }

    private func updateListContentInsetsWhenViewDidLayout() {
        let navigationBarLargeTitleHeight = navigationBarLargeTitleView.bounds.height
        listView.contentInset.top =
            navigationBarLargeTitleHeight +
            theme.listContentTopInset
    }
}

extension AccountSelectionListScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addNavigationBarLargeTitle() {
        view.addSubview(navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.top == theme.navigationBarEdgeInsets.top
            $0.leading == theme.navigationBarEdgeInsets.leading
            $0.trailing == theme.navigationBarEdgeInsets.trailing
        }
    }

    private func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension AccountSelectionListScreen {
    enum Event {
        case didSelect(AccountHandle)
    }
}
