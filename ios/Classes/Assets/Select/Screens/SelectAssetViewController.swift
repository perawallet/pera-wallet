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
import MacaroonUIKit

final class SelectAssetViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = SelectAssetViewControllerListLayout.build()
        let collectionView =
        UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(AssetPreviewCell.self)
        return collectionView
    }()

    private lazy var listLayout = SelectAssetViewControllerListLayout()

    private lazy var accountListDataSource = SelectAssetViewControllerDataSource(
        filter: filter,
        account: account,
        sharedDataController: sharedDataController
    )
    
    private let filter: AssetType?
    private let account: Account
    private let theme: SelectAssetViewControllerTheme

    init(
        filter: AssetType?,
        account: Account,
        theme: SelectAssetViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.filter = filter
        self.account = account
        self.theme = theme
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        navigationItem.title = "send-select-asset".localized
    }
    
    override func setListeners() {
        listView.delegate = self
        listView.dataSource = accountListDataSource
    }

    override func prepareLayout() {
        build()
    }

    private func build() {
        addBackground()
        addListView()
    }
}

extension SelectAssetViewController {
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

extension SelectAssetViewController {
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

extension SelectAssetViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if filter != .collectible,
           indexPath.item == .zero {

            let draft = SendTransactionDraft(
                from: account,
                transactionMode: .algo
            )

            open(.sendTransaction(draft: draft), by: .push)
            return
        }

        guard let asset = accountListDataSource[indexPath] else {
            return
        }

        if let collectibleAsset = asset as? CollectibleAsset {
            if collectibleAsset.isPure {
                openSendCollectible(collectibleAsset)
                return
            }
        }

        let draft = SendTransactionDraft(
            from: account,
            transactionMode: .asset(asset)
        )
        open(.sendTransaction(draft: draft), by: .push)
    }

    private func openSendCollectible(
        _ asset: CollectibleAsset
    ) {
        let sendCollectibleDraft = SendCollectibleDraft(
            fromAccount: account,
            collectibleAsset: asset,
            image: nil
        )

        let controller = open(
            .sendCollectible(
                draft: sendCollectibleDraft
            ),
            by: .customPresent(
                presentationStyle: .overCurrentContext,
                transitionStyle: .crossDissolve,
                transitioningDelegate: nil
            ),
            animated: false
        ) as? SendCollectibleViewController

        controller?.eventHandler = {
            [weak self, controller] event in
            guard let self = self else { return }
            switch event {
            case .didCompleteTransaction:
                controller?.dismissScreen(animated: false) {
                    self.popScreen(animated: false)
                }
            }
        }
    }
}
