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
//   AccountSelectScreenDataSource.swift

import Foundation
import UIKit

final class AccountSelectScreenDataSource: NSObject {
    weak var delegate: AccountSelectScreenDataSourceDelegate?

    private let sharedDataController: SharedDataController
    private var accounts = [AccountHandle]()
    private var contacts = [Contact]()
    private(set) var list = [[Any]]()

    var isEmpty: Bool {
        return accounts.isEmpty && contacts.isEmpty
    }

    /// It refers list's status, when keyword is searched
    var isListEmtpy: Bool {
        (list[safe: 0]?.isEmpty ?? false) &&
        (list[safe: 1]?.isEmpty ?? false) &&
        (list[safe: 2]?.isEmpty ?? false)
    }

    init(sharedDataController: SharedDataController) {
        self.sharedDataController = sharedDataController
        super.init()

        accounts = sharedDataController.accountCollection.sorted()
    }

    func loadData() {
        fetchContacts()
    }

    private func fetchContacts() {
        Contact.fetchAll(entity: Contact.entityName) { [weak self] response in
            guard let self = self else {
                return
            }

            switch response {
            case let .results(objects: objects):
                guard let results = objects as? [Contact] else {
                    return
                }

                self.contacts.append(contentsOf: results)
            default:
                break
            }

            self.reloadData()
        }
    }

    private func reloadData() {
        self.list = [accounts, contacts, []]
        delegate?.accountSelectScreenDataSourceDidLoad(self)
    }

    func search(keyword: String?) {

        guard let searchKeyword = keyword else {
            reloadData()
            return
        }

        let filteredAccounts = accounts.filter { account in
            (account.value.name?.containsCaseInsensitive(searchKeyword) ?? false) ||
            (account.value.address.containsCaseInsensitive(searchKeyword))
        }

        let filteredContacts = contacts.filter { contact in
            (contact.name?.containsCaseInsensitive(searchKeyword) ?? false) ||
            (contact.address?.containsCaseInsensitive(searchKeyword) ?? false)
        }

        var searchedAccounts: [Account] = []
        if filteredAccounts.isEmpty && filteredContacts.isEmpty && AlgorandSDK().isValidAddress(searchKeyword) {
            searchedAccounts = [
                Account(address: searchKeyword, type: .standard)
            ]
        }

        self.list = [filteredAccounts, filteredContacts, searchedAccounts]
    }

    func item(at indexPath: IndexPath) -> Any? {
        guard let safeArray = list[safe: indexPath.section] else {
            return nil
        }

        return safeArray[safe: indexPath.item]
    }
}

extension AccountSelectScreenDataSource:
UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list[safe: section]?.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        // First section shows Accounts
        if indexPath.section == 0 {
            let cell = collectionView.dequeue(AccountPreviewCell.self, at: indexPath)

            if let account = list[safe:0]?[safe: indexPath.item] as? AccountHandle {
                let accountNameViewModel = AuthAccountNameViewModel(account.value)
                let preview = CustomAccountPreview(accountNameViewModel)
                cell.bindData(AccountPreviewViewModel(preview))
            }

            return cell
        } else if indexPath.section == 1{
            let cell = collectionView.dequeue(SelectContactCell.self, at: indexPath)
            let theme = SelectContactViewTheme()

            if let contact = list[safe:1]?[safe: indexPath.item] as? Contact {
                cell.bindData(
                    ContactsViewModel(
                        contact: contact,
                        imageSize: CGSize(width: theme.imageSize.w, height: theme.imageSize.h)
                    )
                )
            }

            return cell
        } else {
            let cell = collectionView.dequeue(AccountPreviewCell.self, at: indexPath)

            if let account = list[safe:2]?[safe: indexPath.item] as? Account {
                let accountNameViewModel = AccountNameViewModel(account: account)
                let preview = CustomAccountPreview(accountNameViewModel)
                cell.bindData(AccountPreviewViewModel(preview))
            }

            return cell
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return list.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        let headerView = collectionView.dequeueHeader(
            TitleHeaderSupplementaryView.self,
            at: indexPath
        )

        headerView.configureAppearance()

        if indexPath.section == 0 {
            headerView.bind(SelectAccountHeaderViewModel(.accounts))
        } else if indexPath.section == 1 {
            headerView.bind(SelectAccountHeaderViewModel(.contacts))
        } else {
            headerView.bind(SelectAccountHeaderViewModel(.search))
        }

        return headerView
    }

}

protocol AccountSelectScreenDataSourceDelegate: AnyObject {
    func accountSelectScreenDataSourceDidLoad(_ dataSource: AccountSelectScreenDataSource)
}
