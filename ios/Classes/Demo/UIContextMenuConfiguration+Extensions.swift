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

//   UIAction+Custom.swift

import Foundation
import MacaroonUIKit
import UIKit

extension UIContextMenuConfiguration {
    convenience init(
        actionProvider: @escaping UIContextMenuActionProvider
    ) {
        self.init(
            identifier: nil,
            previewProvider: nil,
            actionProvider: actionProvider
        )
    }
}

extension UIContextMenuConfiguration {
    convenience init(
        identifier: NSCopying,
        actionProvider: @escaping UIContextMenuActionProvider
    ) {
        self.init(
            identifier: identifier,
            previewProvider: nil,
            actionProvider: actionProvider
        )
    }
}

extension UITargetedPreview {
    convenience init(
        view: UIView,
        backgroundColor: UIColor
    ) {
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = backgroundColor

        self.init(
            view: view,
            parameters: parameters
        )
    }
}

extension UIMenu {
    convenience init(
        children: [UIMenuElement]
    ) {
        self.init(
            title: "",
            image: nil,
            identifier: nil,
            options: .displayInline,
            children: children
        )
    }
}

extension UIAction {
    convenience init(
        item: UIActionItem,
        handler: @escaping UIActionHandler
    ) {
        self.init(
            title: item.title,
            image: item.image,
            identifier: nil,
            discoverabilityTitle: nil,
            attributes: [],
            state: .off,
            handler: handler
        )
    }
}

struct UIActionItem {
    let title: String
    let image: UIImage?

    static var copyAddress: UIActionItem {
        return UIActionItem(
            title: "qr-creation-copy-address".localized,
            image: "icon-copy-gray".uiImage
        )
    }

    static var copyAssetID: UIActionItem {
        return UIActionItem(
            title: "asset-copy-id".localized,
            image: "icon-copy-gray".uiImage
        )
    }

    static var copyTransactionID: UIActionItem {
        return UIActionItem(
            title: "transaction-menu-copy-id".localized,
            image: "icon-copy-gray".uiImage
        )
    }

    static var copyTransactionNote: UIActionItem {
        return UIActionItem(
            title: "transaction-menu-copy-note".localized,
            image: "icon-copy-gray".uiImage
        )
    }
}
