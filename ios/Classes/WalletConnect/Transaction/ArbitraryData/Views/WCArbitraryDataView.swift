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

//   WCArbitraryDataView.swift

import UIKit
import MacaroonUIKit

final class WCArbitraryDataView: WCSingleTransactionView {
    private lazy var theme = Theme()

    private lazy var fromView = TitledTransactionAccountNameView()
    private lazy var toView = TransactionTextInformationView()
    private lazy var balanceView = TransactionAmountInformationView()
    private lazy var amountView = TransactionAmountInformationView()
    private lazy var feeView = TransactionAmountInformationView()
    private lazy var dataView = TransactionTextInformationView()

    override func prepareLayout() {
        super.prepareLayout()

        addParticipantInformationViews()
        addDataInformationViews()
        addDetailedInformationViews()
    }

    override func configureAppearance() {
        super.configureAppearance()

        backgroundColor = Colors.Defaults.background.uiColor
    }
}

extension WCArbitraryDataView {
    private func addParticipantInformationViews() {
        fromView.customize(theme.accountInformationTheme)
        addParticipantInformationView(fromView)

        toView.customize(theme.textInformationTheme)
        addParticipantInformationView(toView)

        balanceView.customize(theme.amountInformationTheme)
        addParticipantInformationView(balanceView)
    }

    private func addDataInformationViews() {
        amountView.customize(theme.amountInformationTheme)
        addTransactionInformationView(amountView)

        feeView.customize(theme.amountInformationTheme)
        addTransactionInformationView(feeView)
    }

    private func addDetailedInformationViews() {
        dataView.customize(theme.textInformationTheme)
        addDetailedInformationView(dataView)
    }
}

extension WCArbitraryDataView {
    func bind(_ viewModel: WCArbitraryDataViewModel) {
        if let fromInformationViewModel = viewModel.fromInformationViewModel {
            unhideViewAnimatedIfNeeded(fromView)
            fromView.bindData(fromInformationViewModel)
        } else {
            fromView.hideViewInStack()
        }

        if let toInformationViewModel = viewModel.toInformationViewModel {
            unhideViewAnimatedIfNeeded(toView)
            toView.bindData(toInformationViewModel)
        } else {
            toView.hideViewInStack()
        }

        if let balanceViewModel = viewModel.balanceViewModel {
            unhideViewAnimatedIfNeeded(balanceView)
            balanceView.bindData(balanceViewModel)
        } else {
            balanceView.hideViewInStack()
        }

        if let amountViewModel = viewModel.amountViewModel {
            unhideViewAnimatedIfNeeded(amountView)
            amountView.bindData(amountViewModel)
        } else {
            amountView.hideViewInStack()
        }

        if let feeViewModel = viewModel.feeViewModel {
            unhideViewAnimatedIfNeeded(feeView)
            feeView.bindData(feeViewModel)
        } else {
            feeView.hideViewInStack()
        }

        if let dataInformationViewModel = viewModel.dataInformationViewModel {
            showNoteStackView(true)
            unhideViewAnimatedIfNeeded(dataView)
            dataView.bindData(dataInformationViewModel)
        } else {
            showNoteStackView(false)
            dataView.hideViewInStack()
        }
    }

    private func unhideViewAnimatedIfNeeded(_ view: UIView) {
        if view.isHidden {
            UIView.animate(withDuration: 0.3) {
                view.showViewInStack()
            }
        }
    }
}
