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
//  ContactsViewController.swift

import UIKit

class ContactsViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    override var name: AnalyticsScreenName? {
        return .contacts
    }
    
    private lazy var contactsView = ContactsView()
    
    private lazy var emptyStateView = ContactsEmptyView(
        image: img("icon-contacts-empty"),
        title: "contacts-empty-text".localized,
        subtitle: "contacts-empty-detail-text".localized
    )
    
    private lazy var searchEmptyStateView = SearchEmptyView()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
        return refreshControl
    }()
    
    private var contacts = [Contact]()
    private var searchResults = [Contact]()
    
    weak var delegate: ContactsViewControllerDelegate?
    
    override func customizeTabBarAppearence() {
        isTabBarHidden = false
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactAdded(notification:)),
            name: .ContactAddition,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactDeleted(notification:)),
            name: .ContactDeletion,
            object: nil
        )
    }
    
    override func linkInteractors() {
        emptyStateView.delegate = self
        contactsView.delegate = self
        contactsView.contactNameInputView.delegate = self
        contactsView.contactsCollectionView.delegate = self
        contactsView.contactsCollectionView.dataSource = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        contactsView.contactsCollectionView.refreshControl = refreshControl
        searchEmptyStateView.setTitle("contact-search-empty-title".localized)
        searchEmptyStateView.setDetail("contact-search-empty-detail".localized)
        fetchContacts()
    }
    
    private func fetchContacts() {
        Contact.fetchAll(entity: Contact.entityName) { response in
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            
            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }
                
                self.contacts.append(contentsOf: results)
                self.searchResults = self.contacts
                
                if self.searchResults.isEmpty {
                    self.contactsView.contactsCollectionView.contentState = .empty(self.emptyStateView)
                } else {
                    self.contactsView.contactsCollectionView.contentState = .none
                }
                
                self.contactsView.contactsCollectionView.reloadData()
            default:
                break
            }
        }
    }
    
    override func prepareLayout() {
        view.addSubview(contactsView)
        
        contactsView.snp.makeConstraints { make in
            make.top.safeEqualToTop(of: self)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    @objc
    private func didRefreshList() {
        contacts.removeAll()
        fetchContacts()
    }
    
    @objc
    private func didContactAdded(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Contact],
            let contact = userInfo["contact"] else {
                return
        }
        
        if contacts.isEmpty {
            contactsView.contactsCollectionView.contentState = .none
        }
        
        contacts.append(contact)
        
        if let name = contact.name,
            let currentQuery = contactsView.contactNameInputView.inputTextField.text,
            !currentQuery.isEmpty {
            
            if name.lowercased().contains(currentQuery.lowercased()) {
                searchResults.append(contact)
            }
            
            contactsView.contactsCollectionView.reloadData()
            return
        }
        
        searchResults.append(contact)
        
        contactsView.contactsCollectionView.reloadData()
    }
    
    @objc
    private func didContactDeleted(notification: Notification) {
        contacts.removeAll()
        fetchContacts()
    }
}

extension ContactsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ContactCell.reusableIdentifier,
            for: indexPath) as? ContactCell else {
                fatalError("Index path is out of bounds")
        }
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func configure(_ cell: ContactCell, at indexPath: IndexPath) {
        cell.delegate = self
        
        if indexPath.item < searchResults.count {
            let contact = searchResults[indexPath.item]
            cell.bind(ContactsViewModel(contact: contact, imageSize: CGSize(width: 50.0, height: 50.0)))
        }
    }
}

extension ContactsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: 86.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)
        
        if indexPath.item < searchResults.count {
            let contact = searchResults[indexPath.item]
            
            guard let delegate = delegate else {
                let controller = open(.contactDetail(contact: contact), by: .push) as? ContactInfoViewController
                controller?.delegate = self
                
                return
            }
            
            dismissScreen()
            delegate.contactsViewController(self, didSelect: contact)
        }
    }
}

extension ContactsViewController: InputViewDelegate {
    func inputViewDidReturn(inputView: BaseInputView) {
        view.endEditing(true)
    }
    
    func inputViewDidChangeValue(inputView: BaseInputView) {
        if contacts.isEmpty {
            contactsView.contactsCollectionView.contentState = .empty(emptyStateView)
            return
        }
        
        guard let query = contactsView.contactNameInputView.inputTextField.text,
            !query.isEmpty else {
                contactsView.contactsCollectionView.contentState = .none
                searchResults = contacts
                contactsView.contactsCollectionView.reloadData()
                return
        }
        
        let predicate = NSPredicate(format: "name contains[c] %@", query)
        
        Contact.fetchAll(entity: Contact.entityName, with: predicate) { response in
            switch response {
            case let .results(objects):
                if let contactResults = objects as? [Contact] {
                    self.searchResults = contactResults
                }
            default:
                break
            }
        }
        
        if searchResults.isEmpty {
            contactsView.contactsCollectionView.contentState = .empty(searchEmptyStateView)
        } else {
            contactsView.contactsCollectionView.contentState = .none
        }
        
        contactsView.contactsCollectionView.reloadData()
    }
}

// MARK: ContactCellDelegate

extension ContactsViewController: ContactCellDelegate {
    func contactCellDidTapQRDisplayButton(_ cell: ContactCell) {
        view.endEditing(true)
        
        guard let indexPath = contactsView.contactsCollectionView.indexPath(for: cell) else {
            return
        }
        
        if indexPath.item < searchResults.count {
            let contact = searchResults[indexPath.item]
            
            if let address = contact.address {
                let draft = QRCreationDraft(address: address, mode: .address)
                open(.qrGenerator(title: contact.name, draft: draft, isTrackable: true), by: .present)
            }
        }
    }
}

extension ContactsViewController: AddContactViewControllerDelegate {
    func addContactViewController(_ addContactViewController: AddContactViewController, didSave contact: Contact) {
        if contacts.isEmpty {
            contactsView.contactsCollectionView.contentState = .none
        }
        
        contacts.append(contact)
        
        if let name = contact.name,
            let currentQuery = contactsView.contactNameInputView.inputTextField.text,
            !currentQuery.isEmpty {
            
            if name.lowercased().contains(currentQuery.lowercased()) {
                searchResults.append(contact)
            }
            
            contactsView.contactsCollectionView.reloadData()
            return
        }
        
        searchResults.append(contact)
        
        contactsView.contactsCollectionView.reloadData()
    }
}

extension ContactsViewController: ContactInfoViewControllerDelegate {
    func contactInfoViewController(_ contactInfoViewController: ContactInfoViewController, didUpdate contact: Contact) {
        if let updatedContact = contacts.firstIndex(of: contact) {
            contacts[updatedContact] = contact
        }
        
        guard let index = searchResults.firstIndex(of: contact) else {
            return
        }
        
        searchResults[index] = contact
        
        contactsView.contactsCollectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
    }
}

extension ContactsViewController: ContactsEmptyViewDelegate {
    func contactsEmptyViewDidTapAddContactButton(_ contactsEmptyView: ContactsEmptyView) {
        let controller = self.open(.addContact(mode: .new()), by: .push) as? AddContactViewController
        controller?.delegate = self
    }
}

extension ContactsViewController: ContactsViewDelegate {
    func contactsViewDidTapAddButton(_ contactsView: ContactsView) {
        let controller = open(.addContact(mode: .new()), by: .push) as? AddContactViewController
        controller?.delegate = self
    }
}

extension ContactsViewController {
    func removeHeader() {
        contactsView.removeHeader()
    }
}

protocol ContactsViewControllerDelegate: AnyObject {
    func contactsViewController(_ contactsViewController: ContactsViewController, didSelect contact: Contact)
}
