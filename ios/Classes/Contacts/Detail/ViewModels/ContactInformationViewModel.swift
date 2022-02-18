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
//   ContactInformationViewModel.swift

import Foundation
import UIKit

final class ContactInformationViewModel {
    private(set) var image: UIImage?
    private(set) var name: String?
    private(set) var address: String?
    private(set) var shortAddress: String?

    init(_ contact: Contact) {
        if let imageData = contact.image,
           let image = UIImage(data: imageData) {
            let resizedImage = image.convert(to: CGSize(width: 80, height: 80))
            self.image = resizedImage
        } else {
            self.image = "icon-user-placeholder".uiImage
        }

        name = contact.name
        address = contact.address
        shortAddress = address.shortAddressDisplay()
    }
}