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

final class SearchBarItemView:
    View,
    ListReusable,
    SearchInputViewDelegate {
    weak var delegate: SearchBarItemViewDelegate?

    var input: String? {
        return searchInputView.text
    }

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
    func beginEditing() {
        searchInputView.beginEditing()
    }

    func endEditing() {
        searchInputView.endEditing()
    }
}

extension SearchBarItemView {
    private func addSearchInputView(_ theme: SearchBarItemViewTheme) {
        searchInputView.customize(theme.searchInput)

        addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }

        searchInputView.delegate = self
    }
}

/// <mark>
/// SearchInputViewDelegate
extension SearchBarItemView {
    func searchInputViewDidBeginEditing(
        _ view: SearchInputView
    ) {
        delegate?.searchBarItemViewDidBeginEditing(self)
    }

    func searchInputViewDidEdit(
        _ view: SearchInputView
    ) {
        delegate?.searchBarItemViewDidEdit(self)
    }

    func searchInputViewDidTapRightAccessory(
        _ view: SearchInputView
    ) {
        delegate?.searchBarItemViewDidTapRightAccessory(self)
    }

    func searchInputViewDidReturn(
        _ view: SearchInputView
    ) {
        delegate?.searchBarItemViewDidReturn(self)
    }

    func searchInputViewDidEndEditing(
        _ view: SearchInputView
    ) {
        delegate?.searchBarItemViewDidEndEditing(self)
    }
}

final class SearchBarItemCell:
    CollectionCell<SearchBarItemView>,
    SearchBarItemViewDelegate {
    weak var delegate: SearchBarItemCellDelegate?

    var input: String? {
        return contextView.input
    }

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        contextView.delegate = self
    }
}

extension SearchBarItemCell {
    func beginEditing() {
        contextView.beginEditing()
    }

    func endEditing() {
        contextView.endEditing()
    }
}

/// <mark>
/// SearchBarItemViewDelegate
extension SearchBarItemCell {
    func searchBarItemViewDidBeginEditing(
        _ view: SearchBarItemView
    ) {
        delegate?.searchBarItemCellDidBeginEditing(self)
    }

    func searchBarItemViewDidEdit(
        _ view: SearchBarItemView
    ) {
        delegate?.searchBarItemCellDidEdit(self)
    }

    func searchBarItemViewDidTapRightAccessory(
        _ view: SearchBarItemView
    ) {
        delegate?.searchBarItemCellDidTapRightAccessory(self)
    }

    func searchBarItemViewDidReturn(
        _ view: SearchBarItemView
    ) {
        delegate?.searchBarItemCellDidReturn(self)
    }

    func searchBarItemViewDidEndEditing(
        _ view: SearchBarItemView
    ) {
        delegate?.searchBarItemCellDidEndEditing(self)
    }
}

protocol SearchBarItemViewDelegate: AnyObject {
    func searchBarItemViewDidBeginEditing(
        _ view: SearchBarItemView
    )
    func searchBarItemViewDidEdit(
        _ view: SearchBarItemView
    )
    func searchBarItemViewDidTapRightAccessory(
        _ view: SearchBarItemView
    )
    func searchBarItemViewDidReturn(
        _ view: SearchBarItemView
    )
    func searchBarItemViewDidEndEditing(
        _ view: SearchBarItemView
    )
}

protocol SearchBarItemCellDelegate: AnyObject {
    func searchBarItemCellDidBeginEditing(
        _ cell: SearchBarItemCell
    )
    func searchBarItemCellDidEdit(
        _ cell: SearchBarItemCell
    )
    func searchBarItemCellDidTapRightAccessory(
        _ cell: SearchBarItemCell
    )
    func searchBarItemCellDidReturn(
        _ cell: SearchBarItemCell
    )
    func searchBarItemCellDidEndEditing(
        _ cell: SearchBarItemCell
    )
}
