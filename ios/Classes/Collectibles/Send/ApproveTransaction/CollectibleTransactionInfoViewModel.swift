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

//   CollectibleTransactionInfoViewModel.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

struct CollectibleTransactionInfoViewModel: ViewModel {
    private(set) var title: EditText?
    private(set) var icon: ImageSource?
    private(set) var value: EditText?
    private(set) var valueStyle: TextStyle?

    init(
        _ information: CollectibleTransactionInformation
    ) {
        bindTitle(information)
        bindIcon(information)
        bindValue(information)
        bindValueStyle(information)
    }
}

extension CollectibleTransactionInfoViewModel {
    private mutating func bindTitle(
        _ information: CollectibleTransactionInformation
    ) {
        title = getTitle(information.title)
    }

    private mutating func bindIcon(
        _ information: CollectibleTransactionInformation
    ) {
        guard let icon = information.icon else {
            return
        }

        switch icon {
        case .account(let account):
            self.icon = account.typeImage.convert(to: CGSize(width: 24, height: 24))
        case .contact(let contact):
            self.icon = ContactImageProcessor(
                data: contact.image,
                size: CGSize(width: 24, height: 24)
            ).process()
        case .nameService(let nameService):
            self.icon = DefaultURLImageSource(
                url: URL(string: nameService.service.logo),
                size: .resize(CGSize(width: 24, height: 24), .aspectFit),
                shape: .circle,
                scale: 1
            )
        case .custom(let image):
            self.icon = image
        }
    }

    private mutating func bindValue(
        _ information: CollectibleTransactionInformation
    ) {
        value = getValue(information)
    }

    private mutating func bindValueStyle(
        _ information: CollectibleTransactionInformation
    ) {
        if information.isCollectibleSpecificValue {
            valueStyle = [
                .textOverflow(FittingText()),
                .textAlignment(.right),
                .textColor(Colors.Link.primary)
            ]
            return
        }

        valueStyle = [
            .textOverflow(FittingText()),
            .textAlignment(.right),
            .textColor(Colors.Text.main)
        ]
    }
}

extension CollectibleTransactionInfoViewModel {
    private func getTitle(
        _ aTitle: String
    ) -> EditText {
        return .attributedString(
            aTitle
                .bodyRegular()
        )
    }

    private func getValue(
        _ information: CollectibleTransactionInformation
    ) -> EditText {
        let value = information.value

        let attributedString: NSAttributedString
        let alignment: NSTextAlignment = .right

        if information.isCollectibleSpecificValue {
            attributedString = value
                .bodyMedium(alignment: alignment)
        } else {
            attributedString = value
                .bodyRegular(alignment: alignment)
        }

        return .attributedString(
            attributedString
        )
    }
}

struct CollectibleTransactionInformation: Hashable {
    var icon: Icon?
    let title: String
    let value: String
    var isCollectibleSpecificValue = false
    var actionURL: URL?

    enum Icon: Hashable {
        case account(Account)
        case contact(Contact)
        case nameService(NameService)
        case custom(UIImage?)
    }
}
