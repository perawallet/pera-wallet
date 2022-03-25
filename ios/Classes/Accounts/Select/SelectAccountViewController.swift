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
//   SelectAccountViewController.swift


import Foundation
import UIKit

final class SelectAccountViewController: BaseViewController {
    weak var delegate: SelectAccountViewControllerDelegate?

    private let theme = Theme()

    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.listMinimumLineSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.listBackgroundColor
        collectionView.register(AccountPreviewCell.self)
        collectionView.contentInset.top = theme.listContentInsetTop
        return collectionView
    }()

    private let transactionAction: TransactionAction

    private lazy var listLayout = SelectAccountListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = SelectAccountDataSource(listView)

    private var dataController: SelectAccountDataController

    init(
        dataController: SelectAccountDataController,
        transactionAction: TransactionAction,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.transactionAction = transactionAction
        super.init(configuration: configuration)
    }

    deinit {
        sharedDataController.remove(self)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        guard transactionAction != .buyAlgo else {
            return
        }

        addBarButtons()
    }

    override func configureAppearance() {
        view.backgroundColor = AppColors.Shared.System.background.uiColor
        navigationItem.title = "send-algos-select".localized
    }

    override func setListeners() {
        listView.dataSource = listDataSource
        listView.delegate = listLayout
        sharedDataController.add(self)
    }

    override func prepareLayout() {
        addListView()
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
        listLayout.handlers.didSelectAccount = { [weak self] accountHandle in
            guard let self = self else {
                return
            }

            self.delegate?.selectAccountViewController(self, didSelect: accountHandle.value, for: self.transactionAction)
        }
        dataController.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        listView
            .visibleCells
            .forEach {
                let loadingCell = $0 as? AssetPreviewLoadingCell
                loadingCell?.startAnimating()
            }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        listView
            .visibleCells
            .forEach {
                let loadingCell = $0 as? AssetPreviewLoadingCell
                loadingCell?.stopAnimating()
            }
    }
}

extension SelectAccountViewController {
    private func addBarButtons() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            self?.closeScreen(by: .dismiss, animated: true)
        }

        leftBarButtonItems = [closeBarButtonItem]
    }

    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.bottom.equalToSuperview()
        }
    }
}

extension SelectAccountViewController: SharedDataControllerObserver {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didFinishRunning:
            listView.reloadData()

            /// Listen data controller just for the first update
            sharedDataController.remove(self)
        default:
            break
        }
    }
}

enum TransactionAction {
    case send
    case receive
    case buyAlgo
}

protocol SelectAccountViewControllerDelegate: AnyObject {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for transactionAction: TransactionAction
    )
}
