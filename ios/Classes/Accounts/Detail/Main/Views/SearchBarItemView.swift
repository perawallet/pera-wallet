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
//   SearchBarItemView.swift

import UIKit
import MacaroonUIKit

final class SearchBarItemView: View {
    private lazy var searchInputView = SearchInputView()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        customize(SearchBarItemViewTheme(placeholder: "account-detail-assets-search".localized))
    }

    func customize(_ theme: SearchBarItemViewTheme) {
        addSearchInputView(theme)
    }

    func prepareLayout(_ layoutSheet: AddAssetItemViewTheme) {}

    func customizeAppearance(_ styleSheet: AddAssetItemViewTheme) {}
}

extension SearchBarItemView {
    private func addSearchInputView(_ theme: SearchBarItemViewTheme) {
        searchInputView.customize(theme.searchInput)
        searchInputView.isUserInteractionEnabled = false

        addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
}

final class SearchBarItemCell: BaseCollectionViewCell<SearchBarItemView> {
    
}
