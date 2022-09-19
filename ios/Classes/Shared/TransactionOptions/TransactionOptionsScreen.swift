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

//   TransactionOptionsScreen.swift

import Foundation
import MacaroonBottomSheet
import MacaroonUIKit
import MagpieExceptions
import UIKit

final class TransactionOptionsScreen:
    BaseScrollViewController,
    BottomSheetScrollPresentable {

    weak var delegate: TransactionOptionsScreenDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var contextView = TransactionOptionsContextView(actions: [.buyAlgo, .send, .receive, .addAsset, .more])

    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.customizeAppearance([.backgroundColor(Colors.Defaults.background)])
    }

    private func build() {
        addContext()
    }

    override func linkInteractors() {
        super.linkInteractors()

        contextView.startObserving(event: .buyAlgo) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.delegate?.transactionOptionsScreenDidBuyAlgo(self)
        }

        contextView.startObserving(event: .send) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.delegate?.transactionOptionsScreenDidSend(self)
        }

        contextView.startObserving(event: .receive) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.delegate?.transactionOptionsScreenDidReceive(self)
        }

        contextView.startObserving(event: .addAsset) {
            [unowned self] in

            self.delegate?.transactionOptionsScreenDidAddAsset(self)
        }

        contextView.startObserving(event: .more) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.delegate?.transactionOptionsScreenDidMore(self)
        }
    }
}

extension TransactionOptionsScreen {
    private func addContext() {
        addActions()
    }

    private func addActions() {
        contextView.customize(TransactionOptionsViewTheme())
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
            $0.bottom <= 0
        }
    }
}

protocol TransactionOptionsScreenDelegate: AnyObject {
    func transactionOptionsScreenDidBuyAlgo(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )
    func transactionOptionsScreenDidSend(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )

    func transactionOptionsScreenDidReceive(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )
    func transactionOptionsScreenDidAddAsset(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )
    func transactionOptionsScreenDidMore(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )
}
