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
//   ContactDisplayViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ContactDisplayViewModel: ViewModel {
    private(set) var contact: Contact?
    private(set) var name: String?
    private(set) var localAddress: String?

    init(contact: Contact) {
        self.contact = contact
    }

    init(address: String) {
        self.name = address
    }

    init(localAddress: String) {
        self.localAddress = localAddress
    }
}

extension ContactDisplayViewModel {
    var contactImage: UIImage? {
        if let imageData = contact?.image,
           let image = UIImage(data: imageData) {
            let resizedImage = image.convert(to: CGSize(width: 24, height: 24))
            return resizedImage
        }

        return nil
    }
}
