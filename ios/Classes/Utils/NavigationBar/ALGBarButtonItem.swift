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
//  ALGBarButtonItem.swift

import Foundation
import UIKit
import MacaroonUIKit

struct ALGBarButtonItem: BarButtonItem {
    
    var handler: EmptyHandler?
    
    var backgroundColor: UIColor? {
        switch kind {
        case .account(let account):
            let authorization = account.authorization

            if authorization.isNoAuth {
                return Colors.Helpers.negativeLighter.uiColor
            }

            if authorization.isRekeyedToLedger {
                return Colors.Wallet.wallet3.uiColor
            }

            if authorization.isRekeyedToStandard {
                return Colors.Wallet.wallet4.uiColor
            }

            return nil
        default:
            return nil
        }
    }
    
    var corner: Corner? {
        switch kind {
        case .account(let account):
            let authorization = account.authorization

            if authorization.isRekeyed || authorization.isNoAuth {
                return Corner(radius: 8)
            }

            return nil
        default:
            return nil
        }
    }
    
    var title: TitleContent? {
        switch kind {
        case .save:
            return BarButtonItemTitleContent(
                text: "title-save".localized,
                textColor: Colors.Text.main.uiColor,
                font: UIFont.font(withWeight: .bold(size: 12.0))
            )
        case .closeTitle:
            return BarButtonItemTitleContent(
                text: "title-close".localized,
                textColor: Colors.Link.primary.uiColor,
                font: Fonts.DMSans.medium.make(15).uiFont
            )
        case .done(let color):
            return BarButtonItemTitleContent(
                text: "title-done".localized,
                textColor: color,
                font: Fonts.DMSans.medium.make(15).uiFont
            )
        case .skip:
            return BarButtonItemTitleContent(
                text: "title-skip".localized,
                textColor: Colors.Text.main.uiColor,
                font: Fonts.DMSans.medium.make(15).uiFont
            )
        case .dontAskAgain:
            return BarButtonItemTitleContent(
                text: "title-dont-ask".localized,
                textColor: Colors.Text.main.uiColor,
                font: Fonts.DMSans.medium.make(15).uiFont
            )
        case .copy:
            return BarButtonItemTitleContent(
                text: "title-copy".localized,
                textColor: Colors.Link.primary.uiColor,
                font: UIFont.font(withWeight: .medium(size: 16.0))
            )
        case .account(let account):
            let authorization = account.authorization

            if authorization.isRekeyedToLedger {
                return BarButtonItemTitleContent(
                    text: "title-rekeyed".localized,
                    textColor: Colors.Wallet.wallet3Icon.uiColor,
                    font: Typography.captionMedium()
                )
            }

            if authorization.isRekeyedToStandard {
                return BarButtonItemTitleContent(
                    text: "title-rekeyed".localized,
                    textColor: Colors.Wallet.wallet4Icon.uiColor,
                    font: Typography.captionMedium()
                )
            }

            if authorization.isNoAuth {
                return BarButtonItemTitleContent(
                    text: "title-no-auth".localized,
                    textColor: Colors.Helpers.negative.uiColor,
                    font: Typography.captionMedium()
                )
            }

            return nil
        default:
            return nil
        }
    }
    
    var image: ImageContent? {
        switch kind {
        case .back:
            if let icon = img("icon-back") {
                return ImageContent(normal: icon)
            }
            return nil
        case .options:
            if let icon = img("icon-options") {
                return ImageContent(normal: icon)
            }
            return nil
        case .circleAdd:
            if let icon = img("add-icon-40") {
                return ImageContent(normal: icon)
            }
            return nil
        case .add:
            if let icon = img("img-contacts-add") {
                return ImageContent(normal: icon)
            }
            return nil
        case .close(let color):
            if let icon = img("icon-close")?.withRenderingMode(.alwaysTemplate) {
                return ImageContent(normal: icon, tintColor: color)
            }
            return nil
        case .closeTitle:
            return nil
        case .save:
            return nil
        case .qr:
            if let icon = img("icon-qr-scan") {
                return ImageContent(normal: icon)
            }
            return nil
        case .info:
            if let icon = img("icon-info") {
                return ImageContent(normal: icon)
            }
            return nil
        case .done:
            return nil
        case .edit:
            if let icon = img("icon-edit") {
                return ImageContent(normal: icon)
            }
            return nil
        case .paste:
            if let icon = img("icon-paste") {
                return ImageContent(normal: icon)
            }
            return nil
        case .skip:
            return nil
        case .dontAskAgain:
            return nil
        case .copy:
            return nil
        case .share:
            if let icon = img("icon-share") {
                return ImageContent(normal: icon)
            }
            return nil
        case .filter:
            if let icon = img("icon-transaction-filter") {
                return ImageContent(normal: icon)
            }
            return nil
        case .troubleshoot:
            if let icon = img("icon-troubleshoot") {
                return ImageContent(normal: icon)
            }
            return nil
        case  .notification:
            if let icon = img("icon-bar-notification") {
                return ImageContent(normal: icon)
            }
            return nil
        case .newNotification:
            if let icon = img("icon-bar-new-notification") {
                return ImageContent(normal: icon)
            }
            return nil
        case .search:
            if let icon = img("icon-search") {
                return ImageContent(normal: icon)
            }
            return nil
        case .account(let account):
            let authorization = account.authorization

            if authorization.isRekeyedToLedger {
                return ImageContent(
                    normal: "icon-shield-16".templateImage,
                    tintColor: Colors.Wallet.wallet3Icon.uiColor
                )
            }

            if authorization.isRekeyedToStandard {
                return ImageContent(
                    normal: "icon-shield-16".templateImage,
                    tintColor: Colors.Wallet.wallet4Icon.uiColor
                )
            }

            if authorization.isNoAuth {
                return ImageContent(
                    normal: "icon-shield-16".templateImage,
                    tintColor: Colors.Helpers.negative.uiColor
                )
            }

            return ImageContent(normal: account.typeImage)
        case .discoverHome:
            if let icon = img("icon-homepage") {
                let disabledIcon = img("icon-homepage-disabled")
                return ImageContent(normal: icon, disabled: disabledIcon)
            }
            return nil
        case .discoverPrevious:
            if let icon = img("icon-previous") {
                let disabledIcon = img("icon-previous-disabled")
                return ImageContent(normal: icon, disabled: disabledIcon)
            }
            return nil
        case .discoverNext:
            if let icon = img("icon-next") {
                let disabledIcon = img("icon-next-disabled")
                return ImageContent(normal: icon, disabled: disabledIcon)
            }
        case .flexibleSpace:
            return nil
        case .reload:
            if let icon = img("icon-reload") {
                return ImageContent(normal: icon, tintColor: Colors.Text.main.uiColor)
            }
            return nil
        }
        return nil
    }
    
    var size: ALGBarButtonItem.Size {
        switch kind {
        case .back:
            return .compressed(
                BarButtonCompressedSizeInsets(contentInsets: UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0))
            )
        case .options:
            return .explicit(CGSize(width: 40, height: 40))
        case .circleAdd:
            return .explicit(CGSize(width: 40, height: 40))
        case .add:
            return .explicit(CGSize(width: 40, height: 40))
        case .close:
            return .explicit(CGSize(width: 44.0, height: 44.0))
        case .closeTitle:
            return .expanded(
                width: .dynamicWidth(BarButtonExpandedSizeHorizontalInsets(
                    contentInsets: (left: 0.0, right: 0.0),
                    titleInsets: (left: 4.0, right: -4.0))
                ),
                height: .equal(44.0)
            )
        case .qr:
            return .explicit(CGSize(width: 40, height: 40))
        case .save:
            return .expanded(
                width: .dynamicWidth(BarButtonExpandedSizeHorizontalInsets(
                    contentInsets: (left: 0.0, right: 0.0),
                    titleInsets: (left: 4.0, right: -4.0))
                ),
                height: .equal(44.0)
            )
        case .info:
            return .explicit(CGSize(width: 44.0, height: 44.0))
        case .done:
            return .expanded(
                width: .dynamicWidth(BarButtonExpandedSizeHorizontalInsets(
                    contentInsets: (left: 0.0, right: 0.0),
                    titleInsets: (left: 4.0, right: -4.0))
                ),
                height: .equal(44.0)
            )
        case .edit:
            return .explicit(CGSize(width: 40, height: 40))
        case .paste:
            return .explicit(CGSize(width: 44.0, height: 44.0))
        case .skip:
            return .expanded(
                width: .dynamicWidth(BarButtonExpandedSizeHorizontalInsets(
                    contentInsets: (left: 0.0, right: 0.0),
                    titleInsets: (left: 4.0, right: -4.0))
                ),
                height: .equal(44.0)
            )
        case .dontAskAgain:
            return .expanded(
                width: .dynamicWidth(BarButtonExpandedSizeHorizontalInsets(
                    contentInsets: (left: 0.0, right: 0.0),
                    titleInsets: (left: 4.0, right: -4.0))
                ),
                height: .equal(44.0)
            )
        case .copy:
            return .expanded(
                width: .dynamicWidth(BarButtonExpandedSizeHorizontalInsets(
                    contentInsets: (left: 0.0, right: 0.0),
                    titleInsets: (left: 4.0, right: -4.0))
                ),
                height: .equal(44.0)
            )
        case .share:
            return .explicit(CGSize(width: 40, height: 40))
        case .filter:
            return .explicit(CGSize(width: 40, height: 40))
        case .troubleshoot:
            return .explicit(CGSize(width: 40, height: 40))
        case .notification, .newNotification:
            return .explicit(CGSize(width: 40, height: 40))
        case .search:
            return .explicit(CGSize(width: 40, height: 40))
        case .account(let account):
            let authorization = account.authorization

            if authorization.isRekeyed || authorization.isNoAuth {
                let spacing = 4 / 2.0
                let contentInsets = UIEdgeInsets((6, spacing + 6, 6, spacing + 8))
                let titleInsets = UIEdgeInsets((0, spacing, 0, -spacing))
                let imageInsets = UIEdgeInsets((0, -spacing, 0, spacing))
                return .compressed(
                    BarButtonCompressedSizeInsets(
                        contentInsets: contentInsets,
                        titleInsets: titleInsets,
                        imageInsets: imageInsets
                    )
                )
            }

            return .explicit(CGSize(width: 28, height: 28))
        case .discoverHome:
            return .explicit(CGSize(width: 40, height: 40))
        case .discoverNext:
            return .explicit(CGSize(width: 40, height: 40))
        case .discoverPrevious:
            return .explicit(CGSize(width: 40, height: 40))
        case .flexibleSpace:
            return .explicit(CGSize(width: 40, height: 40))
        case .reload:
            return .explicit(CGSize(width: 40, height: 40))
        }
    }
    
    let kind: Kind
    
    init(kind: Kind, handler: EmptyHandler? = nil) {
        
        self.kind = kind
        self.handler = handler
    }
    
    static func back() -> ALGBarButtonItem? {
        return ALGBarButtonItem(kind: .back)
    }

    static func dismiss() -> ALGBarButtonItem? {
        return ALGBarButtonItem(kind: .close(Colors.Text.main.uiColor))
    }

    static func flexibleSpace() -> ALGBarButtonItem {
        return ALGBarButtonItem(kind: .flexibleSpace)
    }
}

extension ALGBarButtonItem {
    
    enum Kind: Hashable {
        case back
        case options
        case circleAdd
        case add
        case notification
        case newNotification
        case close(UIColor? = nil)
        case closeTitle
        case save
        case qr
        case done(UIColor)
        case edit
        case info
        case paste
        case skip
        case dontAskAgain
        case copy
        case share
        case filter
        case troubleshoot
        case search
        case account(Account)
        case discoverNext
        case discoverPrevious
        case discoverHome
        case flexibleSpace
        case reload
    }
}

extension ALGBarButtonItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(kind.hashValue)
    }
    
    static func == (lhs: ALGBarButtonItem, rhs: ALGBarButtonItem) -> Bool {
        return lhs.kind == rhs.kind
    }
}
