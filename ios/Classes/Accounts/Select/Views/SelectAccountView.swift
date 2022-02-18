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
//   SelectAccountView.swift


import Foundation
import UIKit
import MacaroonUIKit

final class SelectAccountView: View {
    private lazy var theme = SelectAccountViewTheme()
    private(set) lazy var searchInputView = SearchInputView()
    private(set) lazy var clipboardView = AccountClipboardView()

    private(set) lazy var listView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.contentInset)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(SelectContactCell.self)
        collectionView.register(AccountPreviewCell.self)
        collectionView.register(header: TitleHeaderSupplementaryView.self)
        return collectionView
    }()

    private lazy var contentStateView = ContentStateView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
        linkInteractors()
    }

    func customize(_ theme: SelectAccountViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addSearchInputView(theme)
        addClipboardView(theme)
        addListView(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func displayClipboard(isVisible: Bool) {
        clipboardView.isHidden = !isVisible

        clipboardView.snp.updateConstraints {
            $0.height.equalTo(isVisible ? theme.clipboardHeight : 0)
        }

        listView.contentInset = isVisible ? UIEdgeInsets(theme.contentInset) : .zero
    }
}

extension SelectAccountView {
    private func addSearchInputView(_ theme: SelectAccountViewTheme) {
        searchInputView.customize(theme.searchInputViewTheme)

        addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addClipboardView(_ theme: SelectAccountViewTheme) {
        clipboardView.customize(theme.clipboardTheme)

        addSubview(clipboardView)
        clipboardView.snp.makeConstraints {
            $0.top.equalTo(searchInputView.snp.bottom).offset(theme.clipboardTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.height.equalTo(theme.clipboardHeight)
        }
    }

    private func addListView(_ theme: SelectAccountViewTheme) {
        addSubview(listView)
        listView.snp.makeConstraints {
            $0.top.equalTo(clipboardView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview()
        }

        listView.backgroundView = contentStateView
    }
}
