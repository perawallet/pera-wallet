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
//   WCAlgosTransactionView.swift

import UIKit

class WCAlgosTransactionView: WCSingleTransactionView {

    weak var delegate: WCAlgosTransactionViewDelegate?

    private lazy var theme = Theme()

    private lazy var fromView = TitledTransactionAccountNameView()
    private lazy var toView = TitledTransactionAccountNameView()
    private lazy var balanceView = TransactionAmountInformationView()

    private lazy var assetInformationView = WCAssetInformationView()

    private lazy var closeInformationView = TransactionTextInformationView()
    private lazy var closeWarningInformationView = WCTransactionWarningView()
    private lazy var rekeyInformationView = TransactionTextInformationView()
    private lazy var rekeyWarningInformationView = WCTransactionWarningView()

    private lazy var amountView = TransactionAmountInformationView()
    private lazy var feeView = TransactionAmountInformationView()
    private lazy var warningFeeView = WCTransactionWarningView()

    private lazy var noteView = TransactionTextInformationView()

    private lazy var topButtonsContainer = HStackView()
    private lazy var rawTransactionButton = UIButton()

    override func configureAppearance() {
        super.configureAppearance()

        backgroundColor = Colors.Defaults.background.uiColor
    }
    override func prepareLayout() {
        super.prepareLayout()
        addParticipantInformationViews()
        addTransactionInformationViews()
        addDetailedInformationViews()
        addButtons()
    }

    override func setListeners() {
        rawTransactionButton.addTarget(self, action: #selector(notifyDelegateToOpenRawTransaction), for: .touchUpInside)
    }
}

extension WCAlgosTransactionView {
    private func addParticipantInformationViews() {
        fromView.customize(theme.accountInformationTheme)
        toView.customize(theme.accountInformationTheme)
        balanceView.customize(theme.amountInformationTheme)
        assetInformationView.customize(theme.assetInformationTheme)

        closeInformationView.customize(theme.textInformationTheme)
        rekeyInformationView.customize(theme.textInformationTheme)

        addParticipantInformationView(fromView)
        addParticipantInformationView(toView)
        addParticipantInformationView(balanceView)
        addParticipantInformationView(assetInformationView)
        addParticipantInformationView(closeInformationView)
        addParticipantInformationView(closeWarningInformationView)
        addParticipantInformationView(rekeyInformationView)
        addParticipantInformationView(rekeyWarningInformationView)
    }

    private func addTransactionInformationViews() {
        amountView.customize(theme.amountInformationTheme)
        feeView.customize(theme.amountInformationTheme)

        addTransactionInformationView(amountView)
        addTransactionInformationView(feeView)
        addTransactionInformationView(warningFeeView)
    }

    private func addDetailedInformationViews() {
        noteView.customize(theme.textInformationTheme)
        addDetailedInformationView(noteView)
    }

    private func addButtons() {
        rawTransactionButton.customizeAppearance(theme.rawTransactionButtonStyle)
        rawTransactionButton.layer.draw(corner: theme.buttonsCorner)

        rawTransactionButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)

        addButton(topButtonsContainer)

        topButtonsContainer.addArrangedSubview(rawTransactionButton)

        let spacer = UIView()
        spacer.setContentCompressionResistancePriority(.required, for: .horizontal)
        topButtonsContainer.addArrangedSubview(spacer)
    }
}

extension WCAlgosTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcAlgosTransactionViewDidOpenRawTransaction(self)
    }
}

extension WCAlgosTransactionView {
    func bind(_ viewModel: WCAlgosTransactionViewModel) {
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

        if let assetInformationViewModel = viewModel.assetInformationViewModel {
            unhideViewAnimatedIfNeeded(assetInformationView)
            assetInformationView.bindData(assetInformationViewModel)
        } else {
            assetInformationView.hideViewInStack()
        }

        if let closeInformationViewModel = viewModel.closeInformationViewModel {
            unhideViewAnimatedIfNeeded(closeInformationView)
            closeInformationView.bindData(closeInformationViewModel)
        } else {
            closeInformationView.hideViewInStack()
        }

        if let warningInformationViewModel = viewModel.closeWarningInformationViewModel {
            unhideViewAnimatedIfNeeded(closeWarningInformationView)
            closeWarningInformationView.bind(warningInformationViewModel)
        } else {
            closeWarningInformationView.hideViewInStack()
        }

        if let rekeyInformationViewModel = viewModel.rekeyInformationViewModel {
            unhideViewAnimatedIfNeeded(rekeyInformationView)
            rekeyInformationView.bindData(rekeyInformationViewModel)
        } else {
            rekeyInformationView.hideViewInStack()
        }

        if let warningInformationViewModel = viewModel.rekeyWarningInformationViewModel {
            unhideViewAnimatedIfNeeded(rekeyWarningInformationView)
            rekeyWarningInformationView.bind(warningInformationViewModel)
        } else {
            rekeyWarningInformationView.hideViewInStack()
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

        if let feeWarningViewModel = viewModel.feeWarningInformationViewModel {
            unhideViewAnimatedIfNeeded(warningFeeView)
            warningFeeView.bind(feeWarningViewModel)
        } else {
            warningFeeView.hideViewInStack()
        }

        if let noteInformationViewModel = viewModel.noteInformationViewModel {
            showNoteStackView(true)
            unhideViewAnimatedIfNeeded(noteView)
            noteView.bindData(noteInformationViewModel)
        } else {
            showNoteStackView(false)
            noteView.hideViewInStack()
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

protocol WCAlgosTransactionViewDelegate: AnyObject {
    func wcAlgosTransactionViewDidOpenRawTransaction(_ wcAlgosTransactionView: WCAlgosTransactionView)
}
