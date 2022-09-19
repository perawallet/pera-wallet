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
//  ContactsViewController.swift

import UIKit

class ContactsViewController: BaseViewController {
    weak var delegate: ContactsViewControllerDelegate?

    override var analyticsScreen: ALGAnalyticsScreen? {
        return .init(name: .contactList)
    }
    
    private lazy var contactsView = ContactsView()
    private lazy var noContentWithActionView = NoContentWithActionView()
    private lazy var searchNoContentView = NoContentView()
    private lazy var refreshControl = UIRefreshControl()
    
    private var contacts = [Contact]()
    private var searchResults = [Contact]()
    
    override func setListeners() {
        super.setListeners()
        
        noContentWithActionView.startObserving(event: .performPrimaryAction) {
            [weak self] in
            guard let self = self else {
                return

            }
            let controller = self.open(.addContact(), by: .push) as? AddContactViewController
            controller?.delegate = self
        }

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

        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
    }
    
    override func linkInteractors() {
        contactsView.searchInputView.delegate = self
        contactsView.contactsCollectionView.delegate = self
        contactsView.contactsCollectionView.dataSource = self
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func bindData() {
        noContentWithActionView.bindData(ContactsNoContentWithActionViewModel())
        searchNoContentView.bindData(ContactsSearchNoContentViewModel())
    }

    override func configureAppearance() {
        super.configureAppearance()
        title = "contacts-title".localized
        contactsView.contactsCollectionView.refreshControl = refreshControl
        fetchContacts()
    }
    
    override func prepareLayout() {
        noContentWithActionView.customize(NoContentWithActionViewCommonTheme())
        searchNoContentView.customize(NoContentViewTopAttachedTheme())

        view.addSubview(contactsView)
        contactsView.snp.makeConstraints {
            $0.top.safeEqualToTop(of: self)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension ContactsViewController {
    @objc
    private func didRefreshList() {
        contactsView.searchInputView.setText(.empty)
        contacts.removeAll()
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
                    self.contactsView.contactsCollectionView.contentState = .empty(self.noContentWithActionView)
                } else {
                    self.contactsView.contactsCollectionView.contentState = .none
                }

                self.contactsView.contactsCollectionView.reloadData()
            default:
                break
            }
        }
    }
}

extension ContactsViewController {
    private func addBarButtons() {
        let addBarButtonItem = ALGBarButtonItem(kind: .add) { [weak self] in
            guard let self = self else {
                return
            }

            let controller = self.open(.addContact(), by: .push) as? AddContactViewController
            controller?.delegate = self
        }

        rightBarButtonItems = [addBarButtonItem]
    }
}

extension ContactsViewController {
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
            let currentQuery = contactsView.searchInputView.text,
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
        let cell = collectionView.dequeue(ContactCell.self, at: indexPath)
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func configure(_ cell: ContactCell, at indexPath: IndexPath) {
        cell.delegate = self
        
        if indexPath.item < searchResults.count {
            let contact = searchResults[indexPath.item]
            cell.bindData(ContactsViewModel(contact: contact, imageSize: CGSize(width: 40, height: 40)))
        }
    }
}

extension ContactsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 68)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)
        
        if indexPath.item < searchResults.count {
            let contact = searchResults[indexPath.item]
            
            guard let delegate = delegate else {
                let controller = open(.contactDetail(contact: contact), by: .push) as? ContactDetailViewController
                controller?.delegate = self
                
                return
            }
            
            dismissScreen()
            delegate.contactsViewController(self, didSelect: contact)
        }
    }
}

extension ContactsViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        if contacts.isEmpty {
            contactsView.contactsCollectionView.contentState = .empty(noContentWithActionView)
            return
        }

        guard let query = view.text,
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
            contactsView.contactsCollectionView.contentState = .empty(searchNoContentView)
        } else {
            contactsView.contactsCollectionView.contentState = .none
        }

        contactsView.contactsCollectionView.reloadData()
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension ContactsViewController: ContactCellDelegate {
    func contactCellDidTapQRDisplayButton(_ cell: ContactCell) {
        view.endEditing(true)
        
        guard let indexPath = contactsView.contactsCollectionView.indexPath(for: cell) else {
            return
        }
        
        if indexPath.item < searchResults.count {
            let contact = searchResults[indexPath.item]
            
            if let address = contact.address {
                let draft = QRCreationDraft(address: address, mode: .address, title: contact.name)
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
           let currentQuery = contactsView.searchInputView.text,
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

extension ContactsViewController: ContactDetailViewControllerDelegate {
    func contactDetailViewController(_ contactDetailViewController: ContactDetailViewController, didUpdate contact: Contact) {
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

protocol ContactsViewControllerDelegate: AnyObject {
    func contactsViewController(_ contactsViewController: ContactsViewController, didSelect contact: Contact)
}
