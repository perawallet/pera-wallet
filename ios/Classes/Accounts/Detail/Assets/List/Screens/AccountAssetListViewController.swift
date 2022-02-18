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
//   AccountAssetListViewController.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AccountAssetListViewController: BaseViewController {
    private lazy var theme = Theme()
    private lazy var listLayout = AccountAssetListLayout(accountHandle: accountHandle, listDataSource: listDataSource)
    private lazy var listDataSource = AccountAssetListDataSource(listView)
    private lazy var dataController = AccountAssetListAPIDataController(accountHandle, sharedDataController)

    typealias DataSource = UICollectionViewDiffableDataSource<AccountAssetsSection, AccountAssetsItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<AccountAssetsSection, AccountAssetsItem>

    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = theme.listBackgroundColor.uiColor
        return collectionView
    }()

    private lazy var transactionActionButton = FloatingActionItemButton(hasTitleLabel: false)
    
    private var accountHandle: AccountHandle

    init(accountHandle: AccountHandle, configuration: ViewControllerConfiguration) {
        self.accountHandle = accountHandle
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                if let accountHandle = self.sharedDataController.accountCollection[self.accountHandle.value.address] {
                    self.accountHandle = accountHandle
                }
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }
        dataController.load()
    }

    override func prepareLayout() {
        super.prepareLayout()
        addListView()

        if !accountHandle.value.isWatchAccount() {
            addTransactionActionButton(theme)
        }

        view.layoutIfNeeded()
    }

    override func linkInteractors() {
        super.linkInteractors()
        listView.dataSource = listDataSource
        listView.delegate = listLayout

        listDataSource.handlers.didAddAsset = { [weak self] in
            guard let self = self else { return }
            let controller = self.open(.addAsset(account: self.accountHandle.value), by: .push)
            (controller as? AssetAdditionViewController)?.delegate = self
        }
    }

    override func setListeners() {
        super.setListeners()
        setListActions()
        setTransactionActionButtonAction()
    }
}

extension AccountAssetListViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addTransactionActionButton(_ theme: Theme) {
        transactionActionButton.image = "fab-swap".uiImage

        view.addSubview(transactionActionButton)
        transactionActionButton.snp.makeConstraints {
            $0.setPaddings(theme.transactionActionButtonPaddings)
        }
    }
}

extension AccountAssetListViewController {
    private func setListActions() {
        listLayout.handlers.didSelectSearch = { [weak self] in
            guard let self = self else {
                return
            }

            let searchScreen = self.open(
                .assetSearch(accountHandle: self.accountHandle),
                by: .present
            ) as? AssetSearchViewController
            
            searchScreen?.handlers.didSelectAsset = { [weak self] compoundAsset in
                guard let self = self else {
                    return
                }

                self.openAssetDetail(compoundAsset)
            }
        }

        listLayout.handlers.didSelectAlgoDetail = { [weak self] in
            guard let self = self else {
                return
            }

            self.openAssetDetail(nil)
        }

        listLayout.handlers.didSelectAsset = { [weak self] compoundAsset in
            guard let self = self else {
                return
            }

            self.openAssetDetail(compoundAsset)
        }
    }

    private func openAssetDetail(
        _ compoundAsset: CompoundAsset?
    ) {
        let screen: Screen
        if let compoundAsset = compoundAsset {
            screen = .assetDetail(draft: AssetTransactionListing(accountHandle: accountHandle, compoundAsset: compoundAsset))
        } else {
            screen = .algosDetail(draft: AlgoTransactionListing(accountHandle: accountHandle))
        }

        open(screen, by: .push)
    }
}

extension AccountAssetListViewController {
    private func setTransactionActionButtonAction() {
        transactionActionButton.addTarget(self, action: #selector(didTapTransactionActionButton), for: .touchUpInside)
    }

    @objc
    private func didTapTransactionActionButton() {
        let viewController = open(
            .transactionFloatingActionButton,
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: nil,
                transitioningDelegate: nil
            ),
            animated: false
        ) as? TransactionFloatingActionButtonViewController

        viewController?.delegate = self
    }
}

extension AccountAssetListViewController: TransactionFloatingActionButtonViewControllerDelegate {
    func transactionFloatingActionButtonViewControllerDidSend(_ viewController: TransactionFloatingActionButtonViewController) {
        log(SendAssetDetailEvent(address: accountHandle.value.address))
        let controller = open(.assetSelection(account: accountHandle.value), by: .present) as? SelectAssetViewController
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
            controller?.closeScreen(by: .dismiss, animated: true)
        }
        controller?.leftBarButtonItems = [closeBarButtonItem]
    }

    func transactionFloatingActionButtonViewControllerDidReceive(_ viewController: TransactionFloatingActionButtonViewController) {
        log(ReceiveAssetDetailEvent(address: accountHandle.value.address))
        let draft = QRCreationDraft(address: accountHandle.value.address, mode: .address, title: accountHandle.value.name)
        open(.qrGenerator(title: accountHandle.value.name ?? accountHandle.value.address.shortAddressDisplay(), draft: draft, isTrackable: true), by: .present)
    }
}

extension AccountAssetListViewController {
    func addAsset(_ assetDetail: AssetInformation) {
        dataController.addedAssetDetails.append(assetDetail)
    }

    func removeAsset(_ assetDetail: AssetInformation) {
        dataController.removedAssetDetails.append(assetDetail)
    }
}

extension AccountAssetListViewController: AssetAdditionViewControllerDelegate {
    func assetAdditionViewController(
        _ assetAdditionViewController: AssetAdditionViewController,
        didAdd assetSearchResult: AssetInformation,
        to account: Account
    ) {
        assetSearchResult.isRecentlyAdded = true
        addAsset(assetSearchResult)
    }
}
