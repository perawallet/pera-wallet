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
//   WCAssetAdditionTransactionView.swift

import UIKit

final class WCAssetAdditionTransactionView: WCSingleTransactionView {
    weak var delegate: WCAssetAdditionTransactionViewDelegate?

    private lazy var theme = Theme()

    private lazy var senderView = TitledTransactionAccountNameView()
    private lazy var toView = TitledTransactionAccountNameView()

    private lazy var assetInformationView = WCAssetInformationView()

    private lazy var closeInformationView = TransactionTextInformationView()
    private lazy var closeWarningInformationView = WCTransactionWarningView()
    private lazy var rekeyInformationView = TransactionTextInformationView()
    private lazy var rekeyWarningInformationView = WCTransactionWarningView()

    private lazy var feeView = TransactionAmountInformationView()
    private lazy var warningFeeView = WCTransactionWarningView()

    private lazy var noteView = TransactionTextInformationView()

    private lazy var topButtonsContainer = HStackView()
    private lazy var bottomButtonsContainer = HStackView()
    private lazy var rawTransactionButton = UIButton()
    private lazy var peraExplorerButton = UIButton()
    private lazy var showUrlButton = UIButton()
    private lazy var showMetaDataButton = UIButton()

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
        showUrlButton.addTarget(self, action: #selector(notifyDelegateToOpenAssetURL), for: .touchUpInside)
        showMetaDataButton.addTarget(self, action: #selector(notifyDelegateToOpenAssetMetadata), for: .touchUpInside)

        assetInformationView.startObserving(event: .performAction) {
            [weak self] in
            guard let self = self else { return }
            self.delegate?.wcAssetAdditionTransactionViewDidOpenAssetDiscovery(self)
        }
    }
}

extension WCAssetAdditionTransactionView {
    private func addParticipantInformationViews() {
        senderView.customize(theme.accountInformationTheme)
        toView.customize(theme.accountInformationTheme)
        assetInformationView.customize(theme.assetInformationTheme)

        closeInformationView.customize(theme.textInformationTheme)
        rekeyInformationView.customize(theme.textInformationTheme)

        addParticipantInformationView(senderView)
        addParticipantInformationView(toView)
        addParticipantInformationView(assetInformationView)
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

        showUrlButton.customizeAppearance(theme.showUrlButtonStyle)
        showUrlButton.layer.draw(corner: theme.buttonsCorner)
        showUrlButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)

        showMetaDataButton.customizeAppearance(theme.showMetaDataButtonStyle)
        showMetaDataButton.layer.draw(corner: theme.buttonsCorner)
        showMetaDataButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)

        addButton(topButtonsContainer)

        topButtonsContainer.spacing = theme.buttonSpacing

        topButtonsContainer.addArrangedSubview(rawTransactionButton)
        topButtonsContainer.addArrangedSubview(peraExplorerButton)

        let spacer = UIView()
        spacer.setContentCompressionResistancePriority(.required, for: .horizontal)
        topButtonsContainer.addArrangedSubview(spacer)

        addButton(bottomButtonsContainer)

        bottomButtonsContainer.spacing = theme.buttonSpacing

        bottomButtonsContainer.addArrangedSubview(showUrlButton)
        bottomButtonsContainer.addArrangedSubview(showMetaDataButton)

        let bottomSpacer = UIView()
        bottomSpacer.setContentCompressionResistancePriority(.required, for: .horizontal)
        bottomButtonsContainer.addArrangedSubview(bottomSpacer)
    }
}

extension WCAssetAdditionTransactionView {
    @objc
    private func notifyDelegateToOpenRawTransaction() {
        delegate?.wcAssetAdditionTransactionViewDidOpenRawTransaction(self)
    }

    @objc
    private func notifyDelegateToOpenPeraExplorer() {
        delegate?.wcAssetAdditionTransactionViewDidOpenPeraExplorer(self)
    }

    @objc
    private func notifyDelegateToOpenAssetURL() {
        delegate?.wcAssetAdditionTransactionViewDidOpenAssetURL(self)
    }

    @objc
    private func notifyDelegateToOpenAssetMetadata() {
        delegate?.wcAssetAdditionTransactionViewDidOpenAssetMetadata(self)
    }
}

extension WCAssetAdditionTransactionView {
    func bind(_ viewModel: WCAssetAdditionTransactionViewModel) {
        if let fromInformationViewModel = viewModel.fromInformationViewModel {
            unhideViewAnimatedIfNeeded(senderView)
            senderView.bindData(fromInformationViewModel)
        } else {
            senderView.hideViewInStack()
        }

        if let toInformationViewModel = viewModel.toInformationViewModel {
            unhideViewAnimatedIfNeeded(toView)
            toView.bindData(toInformationViewModel)
        } else {
            toView.hideViewInStack()
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

        if viewModel.rawTransactionInformationViewModel != nil {
            rawTransactionButton.showViewInStack()
        } else {
            rawTransactionButton.hideViewInStack()
        }

        if viewModel.peraExplorerInformationViewModel != nil {
            peraExplorerButton.showViewInStack()
        } else {
            peraExplorerButton.hideViewInStack()
        }

        if topButtonsContainer.arrangedSubviews.isEmpty {
            topButtonsContainer.hideViewInStack()
        }

        if viewModel.urlInformationViewModel != nil {
            showUrlButton.showViewInStack()
        } else {
            showUrlButton.hideViewInStack()
        }

        if viewModel.metadataInformationViewModel != nil {
            showMetaDataButton.showViewInStack()
        } else {
            showMetaDataButton.hideViewInStack()
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

protocol WCAssetAdditionTransactionViewDelegate: AnyObject {
    func wcAssetAdditionTransactionViewDidOpenRawTransaction(
        _ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView
    )
    func wcAssetAdditionTransactionViewDidOpenPeraExplorer(
        _ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView
    )
    func wcAssetAdditionTransactionViewDidOpenAssetURL(
        _ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView
    )
    func wcAssetAdditionTransactionViewDidOpenAssetMetadata(
        _ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView
    )
    func wcAssetAdditionTransactionViewDidOpenAssetDiscovery(
        _ wcAssetAdditionTransactionView: WCAssetAdditionTransactionView
    )
}
