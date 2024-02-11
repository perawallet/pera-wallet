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
//   WCAssetDeletionTransactionView.swift

import UIKit

class WCAssetDeletionTransactionView: WCSingleTransactionView {
    
    weak var delegate: WCAssetDeletionTransactionViewDelegate?

    private lazy var theme = Theme()

    private lazy var senderView = TitledTransactionAccountNameView()

    private lazy var assetInformationView = WCAssetInformationView()
    private lazy var assetWarningInformationView = WCTransactionWarningView()

    private lazy var closeInformationView = TransactionTextInformationView()
    private lazy var closeWarningInformationView = WCTransactionWarningView()
    private lazy var rekeyInformationView = TransactionTextInformationView()
    private lazy var rekeyWarningInformationView = WCTransactionWarningView()

    private lazy var feeView = TransactionAmountInformationView()
    private lazy var warningFeeView = WCTransactionWarningView()

    private lazy var noteView = TransactionTextInformationView()

    private lazy var topButtonsContainer = HStackView()
    private lazy var rawTransactionButton = UIButton()
    private lazy var peraExplorerButton = UIButton()

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
        peraExplorerButton.addTarget(self, action: #selector(notifyDelegateToOpenPeraExplorer), for: .touchUpInside)

        assetInformationView.startObserving(event: .performAction) {
            [weak self] in
            guard let self = self else { return }
            self.delegate?.wcAssetDeletionTransactionViewDidOpenAssetDiscovery(self)
        }
    }
}

extension WCAssetDeletionTransactionView {
    private func addParticipantInformationViews() {
        senderView.customize(theme.accountInformationTheme)
        assetInformationView.customize(theme.assetInformationTheme)

        closeInformationView.customize(theme.textInformationTheme)
        rekeyInformationView.customize(theme.textInformationTheme)

        addParticipantInformationView(senderView)
        addParticipantInformationView(assetInformationView)
        addParticipantInformationView(assetWarningInformationView)
        addParticipantInformationView(closeInformationView)
        addParticipantInformationView(closeWarningInformationView)
        addParticipantInformationView(rekeyInformationView)
        addParticipantInformationView(rekeyWarningInformationView)
    }

    private func addTransactionInformationViews() {
        feeView.customize(theme.amountInformationTheme)

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

        peraExplorerButton.customizeAppearance(theme.peraExplorerButtonStyle)
        peraExplorerButton.layer.draw(corner: theme.buttonsCorner)
        peraExplorerButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)

        addButton(topButtonsContainer)

        topButtonsContainer.spacing = theme.buttonSpacing

        topButtonsContainer.addArrangedSubview(rawTransactionButton)
        topButtonsContainer.addArrangedSubview(peraExplorerButton)

        let spacer = UIView()
        spacer.setContentCompressionResistancePriority(.required, for: .horizontal)
        topButtonsContainer.addArrangedSubview(spacer)
    }
}

extension WCAssetDeletionTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcAssetDeletionTransactionViewDidOpenRawTransaction(self)
    }

    @objc
    private func notifyDelegateToOpenPeraExplorer() {
        delegate?.wcAssetDeletionTransactionViewDidOpenPeraExplorer(self)
    }
}

extension WCAssetDeletionTransactionView {
    func bind(_ viewModel: WCAssetDeletionTransactionViewModel) {
        senderView.bindData(viewModel.fromInformationViewModel)

        if let assetInformationViewModel = viewModel.assetInformationViewModel {
            assetInformationView.bindData(assetInformationViewModel)
            unhideViewAnimatedIfNeeded(assetInformationView)
        } else {
            assetInformationView.hideViewInStack()
        }

        if let assetWarningViewModel = viewModel.assetWarningInformationViewModel,
           viewModel.assetInformationViewModel != nil {
            assetWarningInformationView.bind(assetWarningViewModel)
            unhideViewAnimatedIfNeeded(assetWarningInformationView)
        } else {
            assetWarningInformationView.hideViewInStack()
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

        if let feeInformationViewModel = viewModel.feeViewModel {
            feeView.bindData(feeInformationViewModel)
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

        if viewModel.rawTransactionInformationViewModel != nil {
            unhideViewAnimatedIfNeeded(rawTransactionButton)
        } else {
            rawTransactionButton.hideViewInStack()
        }

        if viewModel.peraExplorerInformationViewModel != nil {
            unhideViewAnimatedIfNeeded(peraExplorerButton)
        } else {
            peraExplorerButton.hideViewInStack()
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

protocol WCAssetDeletionTransactionViewDelegate: AnyObject {
    func wcAssetDeletionTransactionViewDidOpenRawTransaction(
        _ wcAssetDeletionTransactionView: WCAssetDeletionTransactionView
    )
    func wcAssetDeletionTransactionViewDidOpenPeraExplorer(
        _ wcAssetDeletionTransactionView: WCAssetDeletionTransactionView
    )
    func wcAssetDeletionTransactionViewDidOpenAssetDiscovery(
        _ wcAssetDeletionTransactionView: WCAssetDeletionTransactionView
    )
}
