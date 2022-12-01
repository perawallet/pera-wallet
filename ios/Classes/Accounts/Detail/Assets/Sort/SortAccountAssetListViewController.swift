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

//   SortAccountAssetListViewController.swift

import Foundation
import UIKit

final class SortAccountAssetListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = SortAccountAssetListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var listLayout = SortAccountAssetListLayout(
        listDataSource: listDataSource
    )

    private lazy var listDataSource = SortAccountAssetListDataSource(
        listView
    )

    private let dataController: SortAccountAssetListDataController

    init(
        dataController: SortAccountAssetListDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
        bindNavigationItemTitle()
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
                self.listDataSource.apply(snapshot, animatingDifferences: false)
            case .didComplete:
                self.eventHandler?(.didComplete)
            }
        }

        dataController.load()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addList()
    }

    override func linkInteractors() {
        super.linkInteractors()

        linkListViewInteractors()
    }
}

extension SortAccountAssetListViewController {
    private func addBarButtons() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done(Colors.Link.primary.uiColor)) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.dataController.performChanges()
        }

        rightBarButtonItems = [doneBarButtonItem]
    }

    private func bindNavigationItemTitle() {
        title = "title-sort".localized
    }
}

extension SortAccountAssetListViewController {
    private func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension SortAccountAssetListViewController {
    private func linkListViewInteractors() {
        listView.delegate = self
    }
}

extension SortAccountAssetListViewController {
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
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

extension SortAccountAssetListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .sortOption:
            dataController.selectItem(
                at: indexPath
            )
        }
    }
}

extension SortAccountAssetListViewController {
    enum Event {
        case didComplete
    }
}
