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

//   SortAccountListViewController.swift

import UIKit
import MacaroonUIKit

final class SortAccountListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = SortAccountListLayout.build()
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

    private var movingAccountOrderingListItemCellIndexPath: IndexPath?

    private lazy var listLayout = SortAccountListLayout(
        listDataSource: listDataSource
    )
    private lazy var listDataSource = SortAccountListDataSource(
        listView,
        dataController: dataController
    )

    private let dataController: SortAccountListDataController

    init(
        dataController: SortAccountListDataController,
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

    override func setListeners() {
        super.setListeners()

        linkListViewInteractors()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addList()
    }
}

extension SortAccountListViewController {
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

extension SortAccountListViewController {
    private func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension SortAccountListViewController {
    private func linkListViewInteractors() {
        listView.delegate = self

        let gesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPressGesture)
        )
        listView.addGestureRecognizer(gesture)
    }

    @objc
    private func handleLongPressGesture(
        _ gesture: UILongPressGestureRecognizer
    ) {
        listView.isUserInteractionEnabled = false

        switch gesture.state {
        case .began:
            guard let targetIndexPath = listView.indexPathForItem(
                at: gesture.location(in: listView)
            ) else {
                return
            }

            movingAccountOrderingListItemCellIndexPath = targetIndexPath

            listView.beginInteractiveMovementForItem(
                at: targetIndexPath
            )

            recustomizeAccountOrderingCellAppearanceOnMove(
                targetIndexPath,
                isMoving: true
            )
        case .changed:
            listView.updateInteractiveMovementTargetPosition(
                CGPoint(x: listView.center.x, y: gesture.location(in: listView).y)
            )
        case .ended:
            listView.endInteractiveMovement()
            listView.isUserInteractionEnabled = true

            guard let targetIndexPath = movingAccountOrderingListItemCellIndexPath else {
                return
            }

            recustomizeAccountOrderingCellAppearanceOnMove(
                targetIndexPath,
                isMoving: false
            )
        default:
            listView.cancelInteractiveMovement()
            listView.isUserInteractionEnabled = true

            guard let targetIndexPath = movingAccountOrderingListItemCellIndexPath else {
                return
            }

            recustomizeAccountOrderingCellAppearanceOnMove(
                targetIndexPath,
                isMoving: false
            )
        }
    }
}

extension SortAccountListViewController {
    private func recustomizeAccountOrderingCellAppearanceOnMove(
        _ indexPath: IndexPath,
        isMoving: Bool
    ) {
        let cell = listView.cellForItem(
            at: indexPath
        ) as? AccountOrderingListItemCell

        cell?.recustomizeAppearanceOnMove(
            isMoving: isMoving
        )
    }
}

extension SortAccountListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            minimumLineSpacingForSectionAt: section
        )
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

extension SortAccountListViewController {
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
        default:
            break
        }
    }
}

extension SortAccountListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
        atCurrentIndexPath currentIndexPath: IndexPath,
        toProposedIndexPath proposedIndexPath: IndexPath
    ) -> IndexPath {
        if currentIndexPath.section != proposedIndexPath.section {
            movingAccountOrderingListItemCellIndexPath = currentIndexPath

            return currentIndexPath
        }

        movingAccountOrderingListItemCellIndexPath = proposedIndexPath

        return proposedIndexPath
    }
}

extension SortAccountListViewController {
    enum Event {
        case didComplete
    }
}
