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
//  AccountNameViewModel.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class AccountNameViewModel {
    private(set) var accountType: AccountType
    private(set) var image: ImageSource?
    private(set) var name: String?
    
    init(account: Account, hasImage: Bool = true) {
        accountType = account.type
        bindImage(from: account, with: hasImage)
        bindName(from: account, with: hasImage)
    }

    init(contact: Contact, hasImage: Bool = true) {
        accountType = .standard
        bindImage(from: contact, with: hasImage)
        bindName(from: contact, with: hasImage)
    }

    init(nameService: NameService) {
        accountType = .standard
        bindName(from: nameService)
        bindImage(from: nameService)
    }
}

extension AccountNameViewModel {
    private func bindImage(from account: Account, with hasImage: Bool) {
        if !hasImage {
            return
        }

        image = account.typeImage
    }

    private func bindImage(from contact: Contact, with hasImage: Bool) {
        if !hasImage {
            return
        }

        image = ContactImageProcessor(
            data: contact.image
        ).process()
    }

    private func bindName(from account: Account, with hasImage: Bool) {
        if !hasImage {
            name = account.address
            return
        }

        name = account.primaryDisplayName
    }

    private func bindName(from contact: Contact, with hasImage: Bool) {
        if !hasImage {
            name = contact.address
            return
        }

        guard let contactAddress = contact.address else {
            return
        }

        name = contact.name.unwrap(or: contactAddress.shortAddressDisplay)
    }
}

/// <mark> NameService
extension AccountNameViewModel {
    private func bindName(from nameService: NameService) {
        name = nameService.name
    }

    private func bindImage(from nameService: NameService) {
        image = DefaultURLImageSource(url: URL(string: nameService.service.logo))
    }
}
