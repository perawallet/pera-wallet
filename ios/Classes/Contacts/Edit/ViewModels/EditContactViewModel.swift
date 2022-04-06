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
//   EditContactViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

final class EditContactViewModel: PairedViewModel {
    private(set) var image: UIImage?
    private(set) var badgeImage: UIImage?
    private(set) var name: String?
    private(set) var address: String?

    init(_ model: Contact) {
        bindImage(model)
        bindImage()
        bindName(model)
        bindAddress(model)
    }
}

extension EditContactViewModel {
    private func bindImage(_ contact: Contact) {
        image = ContactImageProcessor(
            data: contact.image,
            size: CGSize(width: 80, height: 80),
            fallbackImage: .none
        ).process()
    }

    private func bindImage() {
        badgeImage = "icon-circle-edit".uiImage
    }

    private func bindName(_ contact: Contact) {
        self.name = contact.name
    }

    private func bindAddress(_ contact: Contact) {
        self.address = contact.address
    }
}
