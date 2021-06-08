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
//  CurrencySelectionDataSource.swift

import UIKit
import Magpie

class CurrencySelectionDataSource: NSObject {
    
    private let api: AlgorandAPI
    private var currencies = [Currency]()
    
    weak var delegate: CurrencySelectionDataSourceDelegate?

    init(api: AlgorandAPI) {
        self.api = api
        super.init()
    }
}

extension CurrencySelectionDataSource {
    func loadData(withRefresh refresh: Bool = true) {
        api.getCurrencies { response in
            if refresh {
                self.currencies.removeAll()
            }
            
            switch response {
            case let .success(currencies):
                self.currencies = currencies
                self.delegate?.currencySelectionDataSourceDidFetchCurrencies(self)
            case .failure:
                self.delegate?.currencySelectionDataSourceDidFailToFetch(self)
            }
        }
    }
}

extension CurrencySelectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let currency = currencies[safe: indexPath.item],
           let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SingleSelectionCell.reusableIdentifier,
                for: indexPath
            ) as? SingleSelectionCell {
                let isSelected = api.session.preferredCurrency == currency.id
                cell.contextView.bind(SingleSelectionViewModel(title: currency.name, isSelected: isSelected))
                return cell
        }
    
        fatalError("Index path is out of bounds")
    }
}

extension CurrencySelectionDataSource {
    var isEmpty: Bool {
        return currencies.isEmpty
    }
    
    func currency(at index: Int) -> Currency? {
        return currencies[safe: index]
    }
}

protocol CurrencySelectionDataSourceDelegate: class {
    func currencySelectionDataSourceDidFetchCurrencies(_ currencySelectionDataSource: CurrencySelectionDataSource)
    func currencySelectionDataSourceDidFailToFetch(_ currencySelectionDataSource: CurrencySelectionDataSource)
}
