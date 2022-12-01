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
    private lazy var clipboardCanvasView = UIView()
    private(set) lazy var clipboardView = AccountClipboardView()

    private(set) lazy var listView: UICollectionView = {
        let collectionViewLayout = ExportAccountsConfirmationListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var contentStateView = ContentStateView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }

    func customize(_ theme: SelectAccountViewTheme) {
        addBackground(theme)
        addSearchInputView(theme)
        addListView(theme)
        addClipboardView(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension SelectAccountView {
    private func addBackground(_ theme: SelectAccountViewTheme) {
        customizeAppearance(theme.background)
    }

    private func addSearchInputView(_ theme: SelectAccountViewTheme) {
        searchInputView.customize(theme.searchInputViewTheme)

        addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top == theme.searchInputViewTopPadding
            $0.leading == theme.horizontalPadding
            $0.trailing == theme.horizontalPadding
        }
    }

    private func addClipboardView(_ theme: SelectAccountViewTheme) {
        clipboardCanvasView.customizeAppearance(theme.background)

        addSubview(clipboardCanvasView)
        clipboardCanvasView.snp.makeConstraints {
            $0.top == searchInputView.snp.bottom
            $0.leading == theme.horizontalPadding
            $0.trailing == theme.horizontalPadding
        }

        clipboardView.customize(theme.clipboardTheme)

        clipboardCanvasView.addSubview(clipboardView)
        clipboardView.snp.makeConstraints {
            $0.setPaddings(theme.clipboardPaddings)
        }
    }

    private func addListView(_ theme: SelectAccountViewTheme) {
        addSubview(listView)
        listView.snp.makeConstraints {
            $0.top == searchInputView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        listView.backgroundView = contentStateView
    }
}

extension SelectAccountView {
    func displayClipboard(isVisible: Bool) {
        clipboardCanvasView.isHidden = !isVisible

        UIView.animate(withDuration: 0.3) {
            self.listView.contentInset.top = isVisible ? self.theme.contentInsetTopForClipboard : 0
        }
    }
}
