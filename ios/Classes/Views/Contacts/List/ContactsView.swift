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
//  ContactsView.swift

import UIKit

class ContactsView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    override var endsEditingAfterTouches: Bool {
        return true
    }
    
    weak var delegate: ContactsViewDelegate?
    
    private lazy var contactsHeaderView: MainHeaderView = {
        let view = MainHeaderView()
        view.setTitle("contacts-title".localized)
        view.setQRButtonHidden(true)
        view.setTestNetLabelHidden(true)
        return view
    }()
    
    private(set) lazy var contactNameInputView: SingleLineInputField = {
        let contactNameInputView = SingleLineInputField(displaysExplanationText: false)
        contactNameInputView.placeholderText = "contacts-search".localized
        contactNameInputView.nextButtonMode = .next
        contactNameInputView.inputTextField.autocorrectionType = .no
        return contactNameInputView
    }()
    
    private(set) lazy var contactsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Colors.Background.tertiary
        collectionView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 0.0, right: 0.0)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(ContactCell.self, forCellWithReuseIdentifier: ContactCell.reusableIdentifier)
        collectionView.register(ContactSelectionCell.self, forCellWithReuseIdentifier: ContactSelectionCell.reusableIdentifier)
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    override func linkInteractors() {
        contactsHeaderView.delegate = self
    }
    
    override func prepareLayout() {
        setupContactsHeaderViewLayout()
        setupContactNameInputViewLayout()
        setupContactsCollectionViewLayout()
    }
}

extension ContactsView {
    private func setupContactsHeaderViewLayout() {
        addSubview(contactsHeaderView)
        
        contactsHeaderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    private func setupContactNameInputViewLayout() {
        addSubview(contactNameInputView)
        
        contactNameInputView.snp.makeConstraints { make in
            make.top.equalTo(contactsHeaderView.snp.bottom).offset(layout.current.topInset)
            make.top.equalToSuperview().inset(layout.current.topInset).priority(.low)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func setupContactsCollectionViewLayout() {
        addSubview(contactsCollectionView)
        
        contactsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(contactNameInputView.snp.bottom).offset(layout.current.listOffset)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contactsCollectionView.backgroundView = contentStateView
    }
}

extension ContactsView {
    func removeHeader() {
        contactsHeaderView.removeFromSuperview()
    }
}

extension ContactsView: MainHeaderViewDelegate {
    func mainHeaderViewDidTapAddButton(_ mainHeaderView: MainHeaderView) {
        delegate?.contactsViewDidTapAddButton(self)
    }
    
    func mainHeaderViewDidTapQRButton(_ mainHeaderView: MainHeaderView) {
        
    }
}

extension ContactsView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 4.0
        let listOffset: CGFloat = 16.0
    }
}

protocol ContactsViewDelegate: AnyObject {
    func contactsViewDidTapAddButton(_ contactsView: ContactsView)
}
