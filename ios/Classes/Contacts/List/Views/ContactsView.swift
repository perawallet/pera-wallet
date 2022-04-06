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
//  ContactsView.swift

import UIKit
import MacaroonUIKit

final class ContactsView: View {
    private(set) lazy var theme = ContactsViewTheme()
    private(set) lazy var searchInputView = SearchInputView()

    private(set) lazy var contactsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.contentInset) 
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(ContactCell.self)
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView(bottomInset: -theme.bottomInset)

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }

    func customize(_ theme: ContactsViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addSearchInputView(theme)
        addContactsCollectionView(theme)
    }

    func customizeAppearance(_ styleSheet: StyleSheet) {}

    func prepareLayout(_ layoutSheet: LayoutSheet) {}
}

extension ContactsView {
    private func addSearchInputView(_ theme: ContactsViewTheme) {
        searchInputView.customize(theme.searchInputViewTheme)
                                            
        addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(theme.topInset)
            $0.top.equalToSuperview().inset(theme.topInset).priority(.low)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addContactsCollectionView(_ theme: ContactsViewTheme) {
        addSubview(contactsCollectionView)
        contactsCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchInputView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        contactsCollectionView.backgroundView = contentStateView
    }
}
