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
//   WCAssetCreationTransactionView.swift

import UIKit

class WCAssetCreationTransactionView: WCSingleTransactionView {

    weak var delegate: WCAssetCreationTransactionViewDelegate?

    private lazy var theme = Theme()

    private lazy var senderView = TitledTransactionAccountNameView()
    private lazy var assetInformationView = WCAssetInformationView()
    private lazy var unitNameView = TransactionTextInformationView()

    private lazy var closeInformationView = TransactionTextInformationView()
    private lazy var closeWarningInformationView = WCTransactionWarningView()
    private lazy var rekeyInformationView = TransactionTextInformationView()
    private lazy var rekeyWarningInformationView = WCTransactionWarningView()

    private lazy var amountInformationView = TransactionAmountInformationView()
    private lazy var feeInformationView = TransactionAmountInformationView()
    private lazy var feeWarningView = WCTransactionWarningView()
    private lazy var decimalPlacesView = TransactionTextInformationView()
    private lazy var defaultFrozenView = TransactionTextInformationView()
    private lazy var managerAccountView = TransactionTextInformationView()
    private lazy var reserveAccountView = TransactionTextInformationView()
    private lazy var freezeAccountView = TransactionTextInformationView()
    private lazy var clawbackAccountView = TransactionTextInformationView()

    private lazy var noteView = TransactionTextInformationView()
    private lazy var metadataView = TransactionTextInformationView()

    private lazy var topButtonsContainer = HStackView()
    private lazy var rawTransactionButton = UIButton()
    private lazy var showUrlButton = UIButton()

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
        showUrlButton.addTarget(self, action: #selector(notifyDelegateToOpenAssetURL), for: .touchUpInside)

        assetInformationView.startObserving(event: .performAction) {
            [weak self] in
            guard let self = self else { return }
            self.delegate?.wcAssetCreationTransactionViewDidOpenAssetDiscovery(self)
        }
    }
}

extension WCAssetCreationTransactionView {
    private func addParticipantInformationViews() {
        senderView.customize(theme.accountInformationTheme)
        assetInformationView.customize(theme.assetInformationTheme)
        unitNameView.customize(theme.textInformationTheme)

        closeInformationView.customize(theme.textInformationTheme)
        rekeyInformationView.customize(theme.textInformationTheme)

        addParticipantInformationView(senderView)
        addParticipantInformationView(assetInformationView)
        addParticipantInformationView(unitNameView)
        addParticipantInformationView(closeInformationView)
        addParticipantInformationView(closeWarningInformationView)
        addParticipantInformationView(rekeyInformationView)
        addParticipantInformationView(rekeyWarningInformationView)
    }

    private func addTransactionInformationViews() {
        amountInformationView.customize(theme.amountInformationTheme)
        feeInformationView.customize(theme.amountInformationTheme)

        decimalPlacesView.customize(theme.textInformationTheme)
        defaultFrozenView.customize(theme.textInformationTheme)
        managerAccountView.customize(theme.textInformationTheme)
        reserveAccountView.customize(theme.textInformationTheme)
        freezeAccountView.customize(theme.textInformationTheme)
        clawbackAccountView.customize(theme.textInformationTheme)

        addTransactionInformationView(amountInformationView)
        addTransactionInformationView(feeInformationView)
        addTransactionInformationView(feeWarningView)
        addTransactionInformationView(decimalPlacesView)
        addTransactionInformationView(defaultFrozenView)
        addTransactionInformationView(managerAccountView)
        addTransactionInformationView(reserveAccountView)
        addTransactionInformationView(freezeAccountView)
        addTransactionInformationView(clawbackAccountView)
    }

    private func addDetailedInformationViews() {
        noteView.customize(theme.textInformationTheme)
        metadataView.customize(theme.textInformationTheme)

        addDetailedInformationView(noteView)
        addDetailedInformationView(metadataView)
    }

    private func addButtons() {
        rawTransactionButton.customizeAppearance(theme.rawTransactionButtonStyle)
        rawTransactionButton.layer.draw(corner: theme.buttonsCorner)
        rawTransactionButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)

        showUrlButton.customizeAppearance(theme.showUrlButtonStyle)
        showUrlButton.layer.draw(corner: theme.buttonsCorner)
        showUrlButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)

        addButton(topButtonsContainer)

        topButtonsContainer.spacing = theme.buttonSpacing

        topButtonsContainer.addArrangedSubview(rawTransactionButton)
        topButtonsContainer.addArrangedSubview(showUrlButton)

        let spacer = UIView()
        spacer.setContentCompressionResistancePriority(.required, for: .horizontal)
        topButtonsContainer.addArrangedSubview(spacer)
    }
}

extension WCAssetCreationTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcAssetCreationTransactionViewDidOpenRawTransaction(self)
    }

    @objc
    private func notifyDelegateToOpenAssetURL() {
        delegate?.wcAssetCreationTransactionViewDidOpenAssetURL(self)
    }
}

extension WCAssetCreationTransactionView {
    func bind(_ viewModel: WCAssetCreationTransactionViewModel) {
        senderView.bindData(viewModel.senderInformationViewModel)

        if let assetNameViewModel = viewModel.assetNameViewModel {
            assetInformationView.bindData(assetNameViewModel)
        } else {
            assetInformationView.hideViewInStack()
        }

        if let unitNameViewModel = viewModel.unitNameViewModel {
            unitNameView.bindData(unitNameViewModel)
        } else {
            unitNameView.hideViewInStack()
        }

        if let closeInformationViewModel = viewModel.closeInformationViewModel {
            closeInformationView.bindData(closeInformationViewModel)
        } else {
            closeInformationView.hideViewInStack()
        }

        if let warningInformationViewModel = viewModel.closeWarningInformationViewModel {
            closeWarningInformationView.bind(warningInformationViewModel)
        } else {
            closeWarningInformationView.hideViewInStack()
        }

        if let rekeyInformationViewModel = viewModel.rekeyInformationViewModel {
            rekeyInformationView.bindData(rekeyInformationViewModel)
        } else {
            rekeyInformationView.hideViewInStack()
        }

        if let warningInformationViewModel = viewModel.rekeyWarningInformationViewModel {
            rekeyWarningInformationView.bind(warningInformationViewModel)
        } else {
            rekeyWarningInformationView.hideViewInStack()
        }

        if let amountInformationViewModel = viewModel.amountInformationViewModel {
            amountInformationView.bindData(amountInformationViewModel)
        } else {
            amountInformationView.hideViewInStack()
        }

        if let feeInformationViewModel = viewModel.feeInformationViewModel {
            feeInformationView.bindData(feeInformationViewModel)
        } else {
            feeInformationView.hideViewInStack()
        }

        if let feeWarningViewModel = viewModel.feeWarningViewModel {
            feeWarningView.bind(feeWarningViewModel)
        } else {
            feeWarningView.hideViewInStack()
        }

        if let decimalPlacesViewModel = viewModel.decimalPlacesViewModel {
            decimalPlacesView.bindData(decimalPlacesViewModel)
        } else {
            decimalPlacesView.hideViewInStack()
        }

        if let defaultFrozenViewModel = viewModel.defaultFrozenViewModel {
            defaultFrozenView.bindData(defaultFrozenViewModel)
        } else {
            defaultFrozenView.hideViewInStack()
        }

        if let managerAccountViewModel = viewModel.managerAccountViewModel {
            managerAccountView.bindData(managerAccountViewModel)
        } else {
            managerAccountView.hideViewInStack()
        }

        if let freezeAccountViewModel = viewModel.freezeAccountViewModel {
            freezeAccountView.bindData(freezeAccountViewModel)
        } else {
            freezeAccountView.hideViewInStack()
        }

        if let reserveAccountViewModel = viewModel.reserveAccountViewModel {
            reserveAccountView.bindData(reserveAccountViewModel)
        } else {
            reserveAccountView.hideViewInStack()
        }

        if let clawbackAccountViewModel = viewModel.clawbackAccountViewModel {
            clawbackAccountView.bindData(clawbackAccountViewModel)
        } else {
            clawbackAccountView.hideViewInStack()
        }

        if let noteInformationViewModel = viewModel.noteInformationViewModel {
            noteView.bindData(noteInformationViewModel)
        } else {
            noteView.hideViewInStack()
        }

        if let metadataInformationViewModel = viewModel.metadataInformationViewModel {
            metadataView.bindData(metadataInformationViewModel)
        } else {
            metadataView.hideViewInStack()
        }

        let shouldShowNotStackView = !noteView.isHidden || !metadataView.isHidden
        showNoteStackView(shouldShowNotStackView)

        if viewModel.rawTransactionInformationViewModel != nil {
            rawTransactionButton.showViewInStack()
        } else {
            rawTransactionButton.hideViewInStack()
        }

        if viewModel.assetURLInformationViewModel != nil {
            showUrlButton.showViewInStack()
        } else {
            showUrlButton.hideViewInStack()
        }
    }
}

protocol WCAssetCreationTransactionViewDelegate: AnyObject {
    func wcAssetCreationTransactionViewDidOpenRawTransaction(
        _ wcAssetCreationTransactionView: WCAssetCreationTransactionView
    )
    func wcAssetCreationTransactionViewDidOpenAssetURL(
        _ wcAssetCreationTransactionView: WCAssetCreationTransactionView
    )
    func wcAssetCreationTransactionViewDidOpenAssetDiscovery(
        _ wcAssetCreationTransactionView: WCAssetCreationTransactionView
    )
}
