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
//  ContactsViewModel.swift

import UIKit
import MacaroonUIKit

final class ContactsViewModel: Hashable {
    /// <note>
    /// For uniqueness purposes, we need to store the address of the account.
    private let underlyingAddress: String?

    private(set) var fullAddress: String?
    private(set) var image: UIImage?
    private(set) var name: EditText?
    private(set) var address: String?

    init(contact: Contact, imageSize: CGSize) {
        self.underlyingAddress = contact.address

        fullAddress = contact.address
        bindImage(from: contact, with: imageSize)
        bindName(contact)
        bindAddress(contact)
    }
}

extension ContactsViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(name)
        hasher.combine(underlyingAddress)
    }

    static func == (
        lhs: ContactsViewModel,
        rhs: ContactsViewModel
    ) -> Bool {
        return lhs.name == rhs.name &&
        lhs.address == rhs.underlyingAddress
    }
}

extension ContactsViewModel {
    private func bindImage(from contact: Contact, with imageSize: CGSize) {
        image = ContactImageProcessor(
            data: contact.image,
            size: imageSize
        ).process()
    }

    private func bindName(_ contact: Contact) {
        name = .string(contact.name)
    }

    private func bindAddress(_ contact: Contact) {
        address = contact.address?.shortAddressDisplay
    }
}
