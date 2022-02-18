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
//  CurrencySelectionDataSource.swift

import UIKit
import MagpieCore

class CurrencySelectionDataSource: NSObject {
    
    private let api: ALGAPI
    private var currencies = [Currency]()
    
    weak var delegate: CurrencySelectionDataSourceDelegate?

    init(api: ALGAPI) {
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
            case let .success(currencyList):
                self.currencies = currencyList.items
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
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SingleSelectionCell.reusableIdentifier,
            for: indexPath) as? SingleSelectionCell else {
                fatalError("Index path is out of bounds")
            }
        
        if let currency = currencies[safe: indexPath.item] {
            let isSelected = api.session.preferredCurrency == currency.id
            cell.bindData(SingleSelectionViewModel(title: currency.name, isSelected: isSelected))
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

protocol CurrencySelectionDataSourceDelegate: AnyObject {
    func currencySelectionDataSourceDidFetchCurrencies(_ currencySelectionDataSource: CurrencySelectionDataSource)
    func currencySelectionDataSourceDidFailToFetch(_ currencySelectionDataSource: CurrencySelectionDataSource)
}
