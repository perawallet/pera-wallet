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
//  SelectAssetViewController.swift

import UIKit

final class SelectAssetViewController: BaseViewController {
    private let theme = Theme()
    private lazy var accountListDataSource = SelectAssetViewControllerDataSource(
        account: account,
        sharedDataController: sharedDataController
    )
    private lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.listMinimumLineSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.listBackgroundColor
        collectionView.register(AssetPreviewCell.self)
        collectionView.contentInset.top = theme.listContentInsetTop
        return collectionView
    }()
    
    private let account: Account
    
    init(
        account: Account,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = theme.listBackgroundColor
        navigationItem.title = "send-select-asset".localized
    }
    
    override func setListeners() {
        listView.delegate = self
        listView.dataSource = accountListDataSource
    }

    override func prepareLayout() {
        addListView()
    }
}

extension SelectAssetViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview().inset(theme.listLeadingInset)
            $0.top.bottom.equalToSuperview()
        }
    }
}

extension SelectAssetViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: theme.listItemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let draft: SendTransactionDraft
        if indexPath.item == .zero {
            draft = SendTransactionDraft(from: account, transactionMode: .algo)
        } else {
            guard let compoundAsset = accountListDataSource[indexPath] else {
                return
            }

            draft = SendTransactionDraft(from: account, transactionMode: .assetDetail(compoundAsset.detail))
        }

        open(.sendTransaction(draft: draft), by: .push)
    }
}
