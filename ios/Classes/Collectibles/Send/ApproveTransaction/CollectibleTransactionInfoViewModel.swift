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

import MacaroonUIKit
import UIKit

struct CollectibleTransactionInfoViewModel: ViewModel {
    private(set) var title: EditText?
    private(set) var icon: UIImage?
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
                .textColor(AppColors.Components.Link.primary)
            ]
            return
        }

        valueStyle = [
            .textOverflow(FittingText()),
            .textAlignment(.right),
            .textColor(AppColors.Components.Text.main)
        ]
    }
}

extension CollectibleTransactionInfoViewModel {
    private func getTitle(
        _ aTitle: String
    ) -> EditText {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23

        return .attributedString(
            aTitle
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .textAlignment(.left),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
        )
    }

    private func getValue(
        _ information: CollectibleTransactionInformation
    ) -> EditText {
        let font: CustomFont

        if information.isCollectibleSpecificValue {
            font = Fonts.DMSans.medium.make(15)
        } else {
            font = Fonts.DMSans.regular.make(15)
        }

        let lineHeightMultiplier = 1.23

        return .attributedString(
            information.value
                .attributed([
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .lineBreakMode(.byWordWrapping),
                        .textAlignment(.right),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ])
                ])
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
        case custom(UIImage?)
    }
}
