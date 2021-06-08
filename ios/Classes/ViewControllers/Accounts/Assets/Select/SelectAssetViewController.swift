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
//  SelectAssetViewController.swift

import UIKit

class SelectAssetViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: SelectAssetViewControllerDelegate?
    
    private lazy var selectAssetView = SelectAssetView()

    private lazy var emptyStateView = SearchEmptyView()
    
    private var accounts = [Account]()
    
    private let transactionAction: TransactionAction
    
    private let layoutBuilder = AssetListLayoutBuilder()
    
    private let filterOption: FilterOption
    
    init(
        transactionAction: TransactionAction,
        filterOption: FilterOption,
        configuration: ViewControllerConfiguration
    ) {
        self.transactionAction = transactionAction
        self.filterOption = filterOption
        super.init(configuration: configuration)
        accounts = initAccounts(with: filterOption)
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
    
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.tertiary
        setTertiaryBackgroundColor()
        navigationItem.title = "send-select-asset".localized
        emptyStateView.setTitle("asset-not-found-title".localized)
    }
    
    override func setListeners() {
        selectAssetView.accountsCollectionView.delegate = self
        selectAssetView.accountsCollectionView.dataSource = self
    }

    override func prepareLayout() {
        setupSelectAssetViewLayout()
    }
}

extension SelectAssetViewController {
    private func setupSelectAssetViewLayout() {
        view.addSubview(selectAssetView)
        
        selectAssetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func initAccounts(with filter: FilterOption) -> [Account] {
        guard var allAccounts = session?.accounts,
              !allAccounts.isEmpty else {
            selectAssetView.accountsCollectionView.contentState = .empty(emptyStateView)
            return []
        }

        selectAssetView.accountsCollectionView.contentState = .none
        
        allAccounts.removeAll { account -> Bool in
            account.isWatchAccount()
        }
        
        switch filterOption {
        case .none:
            return allAccounts
        case .algos:
            allAccounts.forEach { $0.assetDetails.removeAll() }
            return allAccounts
        case let .asset(assetDetail):
            let filteredAccounts = allAccounts.filter { account -> Bool in
                account.assetDetails.contains { detail -> Bool in
                     assetDetail.id == detail.id
                }
            }
            
            filteredAccounts.forEach { account in
                account.assetDetails.removeAll { asset -> Bool in
                    assetDetail.id != asset.id
                }
            }
            
            return filteredAccounts
        }
    }
}

extension SelectAssetViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let account = accounts[section]
        
        switch filterOption {
        case .none:
            if account.assetDetails.isEmpty {
                return 1
            }
            
            return account.assetDetails.count + 1
        case .algos,
             .asset:
            return 1
        }
    }
}

extension SelectAssetViewController {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch filterOption {
        case .none:
            if indexPath.item == 0 {
                return dequeueAlgoAssetCell(in: collectionView, cellForItemAt: indexPath)
            }
            return dequeueAssetCell(in: collectionView, cellForItemAt: indexPath)
        case .algos:
            return dequeueAlgoAssetCell(in: collectionView, cellForItemAt: indexPath)
        case .asset:
            return dequeueAssetCell(in: collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func dequeueAlgoAssetCell(in collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlgoAssetCell.reusableIdentifier,
            for: indexPath) as? AlgoAssetCell else {
                fatalError("Index path is out of bounds")
        }
        
        if indexPath.section < accounts.count {
            let account = accounts[indexPath.section]
            cell.bind(AlgoAssetViewModel(account: account))
        }
        
        return cell
    }
    
    private func dequeueAssetCell(in collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let account = accounts[indexPath.section]
        let assetDetail: AssetDetail
        
        switch filterOption {
        case .none:
            assetDetail = account.assetDetails[indexPath.item - 1]
        default:
            assetDetail = account.assetDetails[indexPath.item]
        }
        
        let cell = layoutBuilder.dequeueAssetCells(
            in: collectionView,
            cellForItemAt: indexPath,
            for: assetDetail
        )
        
        if let assets = account.assets,
           let asset = assets.first(where: { $0.id == assetDetail.id }) {
            cell.bind(AssetViewModel(assetDetail: assetDetail, asset: asset))
        }
        
        return cell
    }
}

extension SelectAssetViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind != UICollectionView.elementKindSectionHeader {
            fatalError("Unexpected element kind")
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SelectAssetHeaderSupplementaryView.reusableIdentifier,
            for: indexPath
        ) as? SelectAssetHeaderSupplementaryView else {
            fatalError("Unexpected element kind")
        }
        
        let account = accounts[indexPath.section]
        headerView.bind(SelectAssetViewModel(account: account))
        
        headerView.tag = indexPath.section
        
        return headerView
    }
}

extension SelectAssetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right
        if indexPath.item == 0 {
            return CGSize(width: width, height: layout.current.itemHeight)
        } else {
            let account = accounts[indexPath.section]
            let assetDetail = account.assetDetails[indexPath.item - 1]
            
            if assetDetail.hasBothDisplayName() {
                return CGSize(width: width, height: layout.current.multiItemHeight)
            } else {
                return CGSize(width: width, height: layout.current.itemHeight)
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(
            width: UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right,
            height: layout.current.headerHeight
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        return .zero
    }
}

extension SelectAssetViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let account = accounts[safe: indexPath.section] else {
            return
        }
        
        dismissScreen()
        
        switch filterOption {
        case .none:
            if indexPath.item == 0 {
                delegate?.selectAssetViewController(self, didSelectAlgosIn: account, forAction: transactionAction)
            } else {
                if let assetDetail = account.assetDetails[safe: indexPath.item - 1] {
                    delegate?.selectAssetViewController(self, didSelect: assetDetail, in: account, forAction: transactionAction)
                }
            }
        case .algos:
            delegate?.selectAssetViewController(self, didSelectAlgosIn: account, forAction: transactionAction)
        case let .asset(asset):
            if let assetDetail = account.assetDetails.first(where: { filteredAsset -> Bool in
                asset.id == filteredAsset.id
            }) {
                delegate?.selectAssetViewController(self, didSelect: assetDetail, in: account, forAction: transactionAction)
            }
        }
    }
}

extension SelectAssetViewController {
    enum FilterOption {
        case none
        case algos
        case asset(assetDetail: AssetDetail)
    }
}

extension SelectAssetViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultSectionInsets = UIEdgeInsets.zero
        let headerHeight: CGFloat = 48.0
        let itemHeight: CGFloat = 52.0
        let multiItemHeight: CGFloat = 72.0
    }
}

protocol SelectAssetViewControllerDelegate: class {
    func selectAssetViewController(
        _ selectAssetViewController: SelectAssetViewController,
        didSelectAlgosIn account: Account,
        forAction transactionAction: TransactionAction
    )
    func selectAssetViewController(
        _ selectAssetViewController: SelectAssetViewController,
        didSelect assetDetail: AssetDetail,
        in account: Account,
        forAction transactionAction: TransactionAction
    )
}
