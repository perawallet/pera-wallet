// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   BuyGiftCardsWithCryptoIntroductionAlertItem.swift

final class BuyGiftCardsWithCryptoIntroductionAlertItem:
    AlertItem,
    Storable {
    typealias Object = Any

    var isAvailable: Bool { checkAvailability() }

    unowned let delegate: BuyGiftCardsWithCryptoIntroductionAlertItemDelegate

    private lazy var isSeen: Bool = userDefaults.bool(forKey: isSeenKey) {
        didSet {
            saveIsSeen()
        }
    }
    private let isSeenKey: String = "promotion.dialog.buyGiftCardsWithCrypto"

    init(delegate: BuyGiftCardsWithCryptoIntroductionAlertItemDelegate) {
        self.delegate = delegate
    }
}

extension BuyGiftCardsWithCryptoIntroductionAlertItem {
    func makeAlert() -> Alert {
        isSeen = true

        let title = "buy-gift-cards-with-crypto-alert-title"
            .localized
            .bodyLargeMedium(
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
        let body = "buy-gift-cards-with-crypto-alert-body"
            .localized
            .footnoteRegular(
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
        let alert = Alert(
            image: "buy-gift-cards-with-crypto-illustration",
            isNewBadgeVisible: true,
            title: title,
            body: body,
            theme: AlertScreenWithFillingImageTheme()
        )

        let buyGiftCardsAction = makeBuyGiftCardsAction()
        alert.addAction(buyGiftCardsAction)

        let laterAction = makeLaterAction()
        alert.addAction(laterAction)
        return alert
    }

    func cancel() {}
}

extension BuyGiftCardsWithCryptoIntroductionAlertItem {
    private func makeBuyGiftCardsAction() -> AlertAction {
        return AlertAction(
            title: "buy-gift-cards-with-crypto-alert-primary-action".localized,
            style: .primary
        ) {
            [unowned self] in
            self.delegate.buyGiftCardsWithCryptoIntroductionAlertItemDidPerformBuyGiftCardsAction(self)
        }
    }

    private func makeLaterAction() -> AlertAction {
        return AlertAction(
            title: "title-later".localized,
            style: .secondary
        ) {
            [unowned self] in
            self.delegate.buyGiftCardsWithCryptoIntroductionAlertItemDidPerformLaterAction(self)
        }
    }
}

extension BuyGiftCardsWithCryptoIntroductionAlertItem {
    private func checkAvailability() -> Bool {
        return !isSeen
    }
}

extension BuyGiftCardsWithCryptoIntroductionAlertItem {
    private func saveIsSeen() {
        userDefaults.set(
            isSeen,
            forKey: isSeenKey
        )
    }
}

protocol BuyGiftCardsWithCryptoIntroductionAlertItemDelegate: AnyObject {
    func buyGiftCardsWithCryptoIntroductionAlertItemDidPerformBuyGiftCardsAction(_ item: BuyGiftCardsWithCryptoIntroductionAlertItem)
    func buyGiftCardsWithCryptoIntroductionAlertItemDidPerformLaterAction(_ item: BuyGiftCardsWithCryptoIntroductionAlertItem)
}
