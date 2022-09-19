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

//   AppCallAssetListViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class AppCallAssetListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout,
    BottomSheetPresentable {
    private(set) lazy var listView: UICollectionView = {
        let collectionViewLayout = AppCallAssetListLayout.build()
        let collectionView =
        UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(theme.listContentInset)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private(set) lazy var listLayout = AppCallAssetListLayout(
        listDataSource: listDataSource
    )

    private lazy var listDataSource = AppCallAssetListDataSource(listView)

    private let copyToClipboardController: CopyToClipboardController
    let dataController: AppCallAssetListDataController
    private let theme: AppCallAssetListViewControllerTheme

    init(
        dataController: AppCallAssetListDataController,
        copyToClipboardController: CopyToClipboardController,
        theme: AppCallAssetListViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController
        self.theme = theme

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        title = "assets-title".localized
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
        addListView()
    }

    var modalHeight: ModalHeight {
        return theme.calculateModalHeightAsBottomSheet(self)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let asset = dataController.assets[safe: indexPath.item] else {
            return nil
        }

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath
        ) { _ in
            let copyActionItem = UIAction(item: .copyAssetID) {
                [unowned self] _ in
                self.copyToClipboardController.copyID(asset)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return nil
        }

        return UITargetedPreview(
            view: cell,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return nil
        }

        return UITargetedPreview(
            view: cell,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }
}

extension AppCallAssetListViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension AppCallAssetListViewController {
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
