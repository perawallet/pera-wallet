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
//  CurrencySelectionViewController.swift

import UIKit

final class CurrencySelectionViewController: BaseViewController {
    static var didChangePreferredCurrency: Notification.Name {
        return .init(rawValue: "com.algorand.algorand.notification.preferredCurrency.didChange")
    }
    
    private lazy var theme = Theme()
    private lazy var currencySelectionView = SingleSelectionListView()
    
    private lazy var dataSource: CurrencySelectionDataSource = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return CurrencySelectionDataSource(api: api)
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrencies()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "settings-currency".localized
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        currencySelectionView.delegate = self
        currencySelectionView.setDataSource(dataSource)
        currencySelectionView.setListDelegate(self)
        currencySelectionView.setRefreshControl()
        dataSource.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        prepareWholeScreenLayoutFor(currencySelectionView)
    }
}

extension CurrencySelectionViewController: CurrencySelectionDataSourceDelegate {
    func currencySelectionDataSourceDidFetchCurrencies(_ currencySelectionDataSource: CurrencySelectionDataSource) {
        currencySelectionView.endRefreshing()
        currencySelectionView.setNormalState()
        currencySelectionView.reloadData()
    }
    
    func currencySelectionDataSourceDidFailToFetch(_ currencySelectionDataSource: CurrencySelectionDataSource) {
        currencySelectionView.endRefreshing()
        currencySelectionView.setErrorState()
        currencySelectionView.reloadData()
    }
    
    private func getCurrencies() {
        currencySelectionView.setLoadingState()
        dataSource.loadData()
    }
}

extension CurrencySelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCurrency = dataSource.currency(at: indexPath.item) else {
            return
        }
        
        log(CurrencyChangeEvent(currencyId: selectedCurrency.id))

        sharedDataController.stopPolling()
        
        api?.session.preferredCurrency = selectedCurrency.id
        currencySelectionView.reloadData()
        
        sharedDataController.resetPollingAfterPreferredCurrencyWasChanged()
        
        NotificationCenter.default.post(
            name: Self.didChangePreferredCurrency,
            object: self
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: theme.cellWidth, height: theme.cellHeight)
    }
}

extension CurrencySelectionViewController: SingleSelectionListViewDelegate {
    func singleSelectionListViewDidRefreshList(_ singleSelectionListView: SingleSelectionListView) {
        getCurrencies()
    }
    
    func singleSelectionListViewDidTryAgain(_ singleSelectionListView: SingleSelectionListView) {
        getCurrencies()
    }
}
