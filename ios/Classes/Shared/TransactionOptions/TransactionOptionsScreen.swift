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
import UIKit

final class TransactionOptionsScreen:
    BaseScrollViewController,
    BottomSheetScrollPresentable {
    weak var delegate: TransactionOptionsScreenDelegate?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var contextView = TransactionOptionsContextView(actions: makeActions())

    private let account: Account
    private let theme: TransactionOptionsScreenTheme

    init(
        account: Account,
        theme: TransactionOptionsScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
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
    private func makeActions() -> [TransactionOptionListAction] {
        return account.authorization.isWatch
        ? makeActionsForWatchAccount()
        : makeActionsForNonWatchAccount()
    }

    private func makeActionsForNonWatchAccount() -> [TransactionOptionListAction] {
        let buySellAction = makeBuySellAction()
        let swapAction = makeSwapAction()
        let sendAction = makeSendAction()
        let receiveAction = makeReceiveAction()
        let addAssetAction = makeAddAssetAction()
        let moreAction = makeMoreAction()
        return [
            buySellAction,
            swapAction,
            sendAction,
            receiveAction,
            addAssetAction,
            moreAction
        ]
    }
}

extension TransactionOptionsScreen {
    private func makeActionsForWatchAccount() -> [TransactionOptionListAction] {
        let copyAddressAction = makeCopyAddressAction()
        let showAddressAction = makeShowAddressAction()
        let moreAction = makeMoreAction()
        return [
            copyAddressAction,
            showAddressAction,
            moreAction
        ]
    }

    private func makeCopyAddressAction() -> TransactionOptionListAction {
        return TransactionOptionListAction(
            viewModel: CopyAddressTransactionOptionListItemButtonViewModel(account)
        ) {
            [unowned self] _ in
            self.delegate?.transactionOptionsScreenDidTapCopyAddress(self)
        }
    }

    private func makeShowAddressAction() -> TransactionOptionListAction {
        return TransactionOptionListAction(
            viewModel: ShowAddressTransactionOptionListItemButtonViewModel()
        ) {
            [unowned self] _ in
            self.delegate?.transactionOptionsScreenDidTapShowAddress(self)
        }
    }

    private func makeBuySellAction() -> TransactionOptionListAction {
        return TransactionOptionListAction(
            viewModel: BuySellTransactionOptionListItemButtonViewModel()
        ) {
            [unowned self] _ in
            self.delegate?.transactionOptionsScreenDidTapBuySell(self)
        }
    }

    private func makeSwapAction() -> TransactionOptionListAction {
        let swapDisplayStore = SwapDisplayStore()
        let isOnboardedToSwap = swapDisplayStore.isOnboardedToSwap
        var swapActionViewModel = SwapTransactionOptionListItemButtonViewModel(isBadgeVisible: !isOnboardedToSwap)
        return TransactionOptionListAction(
            viewModel: swapActionViewModel
        ) {
            [unowned self] actionView in

            if !isOnboardedToSwap {
                swapActionViewModel.bindIsBadgeVisible(false)
                actionView.bindData(swapActionViewModel)
            }

            self.delegate?.transactionOptionsScreenDidTapSwap(self)
        }
    }

    private func makeSendAction() -> TransactionOptionListAction {
        return TransactionOptionListAction(
            viewModel: SendTransactionOptionListItemButtonViewModel()
        ) {
            [unowned self] _ in
            self.delegate?.transactionOptionsScreenDidTapSend(self)
        }
    }

    private func makeReceiveAction() -> TransactionOptionListAction {
        return TransactionOptionListAction(
            viewModel: ReceiveTransactionOptionListItemButtonViewModel()
        ) {
            [unowned self] _ in
            self.delegate?.transactionOptionsScreenDidTapReceive(self)
        }
    }

    private func makeAddAssetAction() -> TransactionOptionListAction {
        return TransactionOptionListAction(
            viewModel: AddAssetTransactionOptionListActionViewModel()
        ) {
            [unowned self] _ in
            self.delegate?.transactionOptionsScreenDidTapAddAsset(self)
        }
    }

    private func makeMoreAction() -> TransactionOptionListAction {
        return TransactionOptionListAction(
            viewModel: MoreTransactionOptionListItemButtonViewModel()
        ) {
            [unowned self] _ in
            self.delegate?.transactionOptionsScreenDidTapMore(self)
        }
    }
}

protocol TransactionOptionsScreenDelegate: AnyObject {
    func transactionOptionsScreenDidTapCopyAddress(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )
    func transactionOptionsScreenDidTapShowAddress(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )
    func transactionOptionsScreenDidTapBuySell(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )
    func transactionOptionsScreenDidTapSwap(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )
    func transactionOptionsScreenDidTapSend(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )
    func transactionOptionsScreenDidTapReceive(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )
    func transactionOptionsScreenDidTapAddAsset(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )
    func transactionOptionsScreenDidTapMore(
        _ transactionOptionsScreen: TransactionOptionsScreen
    )
}
