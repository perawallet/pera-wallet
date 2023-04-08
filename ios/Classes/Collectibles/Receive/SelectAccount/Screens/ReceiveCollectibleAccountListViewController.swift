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

//   ReceiveCollectibleAccountListViewController.swift

import UIKit
import MacaroonUIKit

final class ReceiveCollectibleAccountListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    private lazy var titleView = Label()

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = ReceiveCollectibleAccountListLayout.build()
        let collectionView =
        UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var listLayout = ReceiveCollectibleAccountListLayout(
        listDataSource: listDataSource
    )

    private lazy var listDataSource = ReceiveCollectibleAccountListDataSource(listView)

    private let dataController: ReceiveCollectibleAccountListDataController
    private let theme: ReceiveCollectibleAccountListViewControllerTheme

    init(
        dataController: ReceiveCollectibleAccountListDataController,
        theme: ReceiveCollectibleAccountListViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.theme = theme

        super.init(configuration: configuration)
    }

    override func prepareLayout() {
        super.prepareLayout()
        build()
    }

    override func setListeners() {
        super.setListeners()

        listView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }
        
        dataController.load()
    }

    private func build() {
        addBackground()
        addTitleView()
        addListView()
    }
}

extension ReceiveCollectibleAccountListViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addTitleView() {
        titleView.customizeAppearance(theme.title)

        view.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.setPaddings(theme.titlePaddings)
        }
    }

    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top == titleView.snp.bottom

            $0.setPaddings((.noMetric, 0, 0, 0))
        }
    }
}

extension ReceiveCollectibleAccountListViewController {
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

extension ReceiveCollectibleAccountListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? PreviewLoadingCell
                loadingCell?.startAnimating()
            default:
                break
            }
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? PreviewLoadingCell
                loadingCell?.stopAnimating()
            default:
                break
            }
        default:
            break
        }
    }
}

extension ReceiveCollectibleAccountListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .account(let item):
            guard let account = dataController[item.address],
                  account.isAvailable else {
                      return
                  }

            open(
                .receiveCollectibleAssetList(account: account),
                by: .push
            )
        default:
            break
        }
    }
}
