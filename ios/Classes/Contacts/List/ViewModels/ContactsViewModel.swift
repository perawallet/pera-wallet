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

final class ContactsViewModel {
    private(set) var image: UIImage?
    private(set) var name: String?
    private(set) var address: String?

    init(contact: Contact, imageSize: CGSize) {
        bindImage(from: contact, with: imageSize)
        bindName(contact)
        bindAddress(contact)
    }
}

extension ContactsViewModel {
    private func bindImage(from contact: Contact, with imageSize: CGSize) {
        if let imageData = contact.image,
           let image = UIImage(data: imageData) {
            self.image = image.convert(to: imageSize)
        } else {
            self.image = img("icon-user-placeholder")
        }
    }

    private func bindName(_ contact: Contact) {
        name = contact.name
    }

    private func bindAddress(_ contact: Contact) {
        address = contact.address?.shortAddressDisplay()
    }
}
