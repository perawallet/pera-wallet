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

    private lazy var contextView = TransactionOptionsContextView(actions: composeActions())

    private let theme: TransactionOptionsScreenTheme

    init(
        theme: TransactionOptionsScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.theme = theme
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addContext()
    }
}

extension TransactionOptionsScreen {
    private func addContext() {
        contextView.customize(theme.context)

        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension TransactionOptionsScreen {
    private func composeActions() -> [TransactionOptionListAction] {
        let buyAlgoAction = TransactionOptionListAction(
            viewModel: BuyAlgoTransactionOptionListItemButtonViewModel()
        ) {
            [weak self] _ in
            guard let self = self else { return }
            self.delegate?.transactionOptionsScreenDidBuyAlgo(self)
        }

        let swapDisplayStore = SwapDisplayStore()
        let isOnboardedToSwap = swapDisplayStore.isOnboardedToSwap

        var swapActionViewModel = SwapTransactionOptionListItemButtonViewModel(isBadgeVisible: !isOnboardedToSwap)
        let swapAction = TransactionOptionListAction(
            viewModel: swapActionViewModel
        ) {
            [weak self] actionView in
            guard let self = self else { return }

            if !isOnboardedToSwap {
                swapActionViewModel.bindIsBadgeVisible(false)
                actionView.bindData(swapActionViewModel)
            }

            self.delegate?.transactionOptionsScreenDidSwap(self)
        }

        let sendAction = TransactionOptionListAction(
            viewModel: SendTransactionOptionListItemButtonViewModel()
        ) {
            [weak self] _ in
            guard let self = self else { return }
            self.delegate?.transactionOptionsScreenDidSend(self)
        }

        let receiveAction = TransactionOptionListAction(
            viewModel: ReceiveTransactionOptionListItemButtonViewModel()
        ) {
            [weak self] _ in
            guard let self = self else { return }
            self.delegate?.transactionOptionsScreenDidReceive(self)
        }

        let addAssetAction = TransactionOptionListAction(
            viewModel: AddAssetTransactionOptionListActionViewModel()
        ) {
            [weak self] _ in
            guard let self = self else { return }
            self.delegate?.transactionOptionsScreenDidAddAsset(self)
        }

        let moreAction = TransactionOptionListAction(
            viewModel: MoreTransactionOptionListItemButtonViewModel()
        ) {
            [weak self] _ in
            guard let self = self else { return }
            self.delegate?.transactionOptionsScreenDidMore(self)
        }

        return [
            buyAlgoAction,
            swapAction,
            sendAction,
            receiveAction,
            addAssetAction,
            moreAction
        ]
    }
}

protocol TransactionOptionsScreenDelegate: AnyObject {
    func transactionOptionsScreenDidBuyAlgo(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )
    func transactionOptionsScreenDidSwap(
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
