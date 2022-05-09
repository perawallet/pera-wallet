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
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var theme = Theme()

    private lazy var listLayout = AccountAssetListLayout(
        isWatchAccount: accountHandle.value.isWatchAccount(),
        listDataSource: listDataSource
    )

    private lazy var listDataSource = AccountAssetListDataSource(listView)
    private lazy var dataController = AccountAssetListAPIDataController(accountHandle, sharedDataController)

    private lazy var buyAlgoResultTransition = BottomSheetTransition(presentingViewController: self)
    
    private lazy var listView: UICollectionView = {
        let collectionViewLayout = AccountAssetListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = theme.listBackgroundColor.uiColor
        return collectionView
    }()

    private lazy var transactionActionButton = FloatingActionItemButton(hasTitleLabel: false)
    
    private var accountHandle: AccountHandle

    init(
        accountHandle: AccountHandle,
        configuration: ViewControllerConfiguration
    ) {
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
                    self.eventHandler?(.didUpdate(accountHandle))
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
        listView.delegate = self
    }

    override func setListeners() {
        super.setListeners()
        setTransactionActionButtonAction()
    }
}

extension AccountAssetListViewController {
    private func addListView() {
        let isWatchAccount = accountHandle.value.isWatchAccount()
        listView.contentInset = isWatchAccount ? .zero : UIEdgeInsets(theme.contentInset)
        
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

extension AccountAssetListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers
        
        guard let listSection = sectionIdentifiers[safe: indexPath.section] else {
            return
        }
        
        switch listSection {
        case .assets:
            guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
                return
            }
            
            switch itemIdentifier {
            case .assetManagement:
                guard let item = cell as? AssetManagementItemCell else {
                    return
                }
                
                item.observe(event: .manage) {
                    [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.eventHandler?(.manageAssets)
                }
                item.observe(event: .add) {
                    [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.eventHandler?(.addAsset)
                }
            default:
                return
            }
        default:
            return
        }
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: indexPath.section] else {
            return
        }

        switch listSection {
        case .assets:
            guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
                return
            }

            switch itemIdentifier {
            case .search:
                let searchScreen = open(
                    .assetSearch(
                        accountHandle: accountHandle,
                        dataController: AssetSearchLocalDataController(
                            accountHandle: accountHandle,
                            sharedDataController: sharedDataController
                        )
                    ),
                    by: .present
                ) as? AssetSearchViewController

                searchScreen?.handlers.didSelectAsset = {
                    [weak self] asset in
                    guard let self = self,
                          let searchScreen = searchScreen else {
                              return
                          }
                    
                    self.openAssetDetail(asset, on: searchScreen)
                }
            case .asset:
                let algoIndex = 2
                
                if indexPath.item == algoIndex {
                    openAlgoDetail()
                    return
                }

                /// Reduce management and algos cells from index
                let assetIndex = indexPath.item - (algoIndex + 1)
                
                if let assetDetail = accountHandle.value.standardAssets[safe: assetIndex] {
                    self.openAssetDetail(assetDetail, on: self)
                }
            default:
                break
            }
        default:
            break
        }
    }
}

extension AccountAssetListViewController {
    private func openAlgoDetail() {
        open(
            .algosDetail(
                draft: AlgoTransactionListing(
                    accountHandle: accountHandle
                )
            ),
            by: .push
        )
    }

    private func openAssetDetail(
        _ asset: StandardAsset,
        on screen: UIViewController
    ) {
        screen.open(
            .assetDetail(
                draft: AssetTransactionListing(
                    accountHandle: accountHandle,
                    asset: asset
                )
            ),
            by: .push
        )
    }
}

extension AccountAssetListViewController {
    private func setTransactionActionButtonAction() {
        transactionActionButton.addTarget(
            self,
            action: #selector(didTapTransactionActionButton),
            for: .touchUpInside
        )
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
        let controller = open(
            .assetSelection(
                filter: nil,
                account: accountHandle.value
            ),
            by: .present
        ) as? SelectAssetViewController
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak controller] in
            controller?.closeScreen(by: .dismiss, animated: true)
        }
        controller?.leftBarButtonItems = [closeBarButtonItem]
    }

    func transactionFloatingActionButtonViewControllerDidReceive(_ viewController: TransactionFloatingActionButtonViewController) {
        log(ReceiveAssetDetailEvent(address: accountHandle.value.address))
        let draft = QRCreationDraft(address: accountHandle.value.address, mode: .address, title: accountHandle.value.name)
        open(.qrGenerator(title: accountHandle.value.name ?? accountHandle.value.address.shortAddressDisplay, draft: draft, isTrackable: true), by: .present)
    }

    func transactionFloatingActionButtonViewControllerDidBuy(
        _ viewController: TransactionFloatingActionButtonViewController
    ) {
        openBuyAlgo()
    }

    private func openBuyAlgo() {
        let draft = BuyAlgoDraft()
        draft.address = accountHandle.value.address

        launchBuyAlgo(draft: draft)
    }
}

extension AccountAssetListViewController {
    func addAsset(_ assetDetail: StandardAsset) {
        dataController.addedAssetDetails.append(assetDetail)
    }

    func removeAsset(_ assetDetail: StandardAsset) {
        dataController.removedAssetDetails.append(assetDetail)
    }
}

extension AccountAssetListViewController {
    enum Event {
        case didUpdate(AccountHandle)
        case manageAssets
        case addAsset
    }
}
