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

//   AppCallTransactionDetailView.swift

import UIKit
import MacaroonUIKit

final class AppCallTransactionDetailView:
    View,
    UIContextMenuInteractionDelegate,
    AppCallTransactionAssetInformationViewDelegate {
    weak var delegate: AppCallTransactionDetailViewDelegate?

    private lazy var verticalStackView = UIStackView()
    private lazy var senderView = TransactionTextInformationView()
    private lazy var applicationIDView = TransactionTextInformationView()
    private lazy var onCompletionView = TransactionTextInformationView()
    private lazy var assetView = AppCallTransactionAssetInformationView()
    private lazy var feeView = TransactionAmountInformationView()
    private lazy var innerTransactionView = TransactionAmountInformationView()
    private lazy var transactionIDView = TransactionTextInformationView()
    private lazy var noteView = TransactionTextInformationView()

    private lazy var openInPeraExplorerButton = UIButton()

    private lazy var senderContextMenuInteraction = UIContextMenuInteraction(delegate: self)
    private lazy var applicationIDContextMenuInteraction = UIContextMenuInteraction(delegate: self)
    private lazy var assetContextMenuInteraction = UIContextMenuInteraction(delegate: self)
    private lazy var transactionIDContextMenuInteraction = UIContextMenuInteraction(delegate: self)
    private lazy var noteContextMenuInteraction = UIContextMenuInteraction(delegate: self)

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        linkInteractors()
    }

    func linkInteractors() {
        senderView.addInteraction(senderContextMenuInteraction)
        applicationIDView.addInteraction(applicationIDContextMenuInteraction)

        assetView.addInteraction(assetContextMenuInteraction)
        assetView.delegate = self

        transactionIDView.addInteraction(transactionIDContextMenuInteraction)
        noteView.addInteraction(noteContextMenuInteraction)

        openInPeraExplorerButton.addTouch(
            target: self,
            action: #selector(notifyDelegateToOpenPeraExplorer)
        )
        innerTransactionView.startObserving(event: .touch) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.notifyDelegateToOpenInnerTransactionList()
        }
    }

    func customize(_ theme: AppCallTransactionDetailViewTheme) {
        addVerticalStackView(theme)
        addSenderView(theme)
        addApplicationIDView(theme)
        addOnCompletionView(theme)
        addAssetView(theme)
        addFeeView(theme)
        addInnerTransactionView(theme)
        addTransactionIDView(theme)
        addNoteView(theme)
        addOpenInPeraExplorerButton(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
}

extension AppCallTransactionDetailView {
    private func addBackground(theme: AppCallTransactionDetailViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    private func addVerticalStackView(_ theme: AppCallTransactionDetailViewTheme) {
        verticalStackView.axis = .vertical
        addSubview(verticalStackView)

        verticalStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.verticalStackViewTopPadding)
            $0.leading.trailing.equalToSuperview()
        }
    }

    private func addSenderView(_ theme: AppCallTransactionDetailViewTheme) {
        senderView.customize(theme.senderViewTheme)

        verticalStackView.addArrangedSubview(senderView)
    }

    private func addApplicationIDView(_ theme: AppCallTransactionDetailViewTheme) {
        applicationIDView.customize(theme.textInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(applicationIDView)
    }

    private func addOnCompletionView(_ theme: AppCallTransactionDetailViewTheme) {
        onCompletionView.customize(theme.onCompletionViewTheme)

        verticalStackView.addArrangedSubview(onCompletionView)
    }

    private func addAssetView(_ theme: AppCallTransactionDetailViewTheme) {
        assetView.customize(theme.assetViewTheme)

        verticalStackView.addArrangedSubview(assetView)
    }

    private func addFeeView(_ theme: AppCallTransactionDetailViewTheme) {
        let feeCanvasView = MacaroonUIKit.BaseView()
        feeCanvasView.addSubview(feeView)
        feeView.snp.makeConstraints {
            $0.top == theme.bottomPaddingForSeparator
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }

        feeView.customize(theme.feeViewTheme)
        feeView.bindData(
            TransactionAmountInformationViewModel(
                title: "transaction-detail-fee".localized
            )
        )

        verticalStackView.addArrangedSubview(feeCanvasView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: feeCanvasView)
        feeView.addSeparator(
            theme.topSeparator,
            padding: theme.separatorPadding
        )
        feeView.addSeparator(
            theme.bottomSeparator,
            padding: theme.separatorPadding
        )
    }

    private func addInnerTransactionView(_ theme: AppCallTransactionDetailViewTheme) {
        innerTransactionView.customize(theme.innerTransactionViewTheme)
        innerTransactionView.bindData(
            TransactionAmountInformationViewModel(
                title: "transaction-detail-inner-transaction-title".localized
            )
        )

        verticalStackView.addArrangedSubview(innerTransactionView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: innerTransactionView)
        innerTransactionView.addSeparator(theme.bottomSeparator, padding: theme.separatorPadding)
    }

    private func addTransactionIDView(_ theme: AppCallTransactionDetailViewTheme) {
        transactionIDView.customize(theme.textInformationViewCommonTheme)

        verticalStackView.addArrangedSubview(transactionIDView)
        verticalStackView.setCustomSpacing(
            theme.bottomPaddingForSeparator,
            after: transactionIDView
        )
        transactionIDView.addSeparator(
            theme.bottomSeparator,
            padding: theme.separatorPadding
        )
    }

    private func addNoteView(_ theme: AppCallTransactionDetailViewTheme) {
        noteView.customize(theme.textInformationViewCommonTheme)
        noteView.isUserInteractionEnabled = true

        verticalStackView.addArrangedSubview(noteView)
        verticalStackView.setCustomSpacing(theme.bottomPaddingForSeparator, after: noteView)
        noteView.addSeparator(theme.bottomSeparator, padding: theme.separatorPadding)
    }

    private func addOpenInPeraExplorerButton(_ theme: AppCallTransactionDetailViewTheme) {
        openInPeraExplorerButton.customizeAppearance(theme.openInPeraExplorerButton)
        openInPeraExplorerButton.layer.draw(corner: theme.buttonsCorner)

        addSubview(openInPeraExplorerButton)
        openInPeraExplorerButton.contentEdgeInsets = UIEdgeInsets(theme.buttonEdgeInsets)

        openInPeraExplorerButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(verticalStackView.snp.bottom).offset(theme.spacingBetweenPropertiesAndActions)
            $0.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + theme.bottomInset)
        }
    }
}

extension AppCallTransactionDetailView {
    func bindData(
        _ viewModel: AppCallTransactionDetailViewModel?,
        currency: CurrencyProvider,
        currencyFormatter: CurrencyFormatter
    ) {
        senderView.bindData(
            TransactionTextInformationViewModel(
                TitledInformation(
                    title: "transaction-detail-sender".localized,
                    detail: viewModel?.sender
                )
            )
        )

        applicationIDView.bindData(
            TransactionTextInformationViewModel(
                title: "wallet-connect-transaction-title-app-id".localized,
                detail: viewModel?.applicationID
            )
        )

        onCompletionView.bindData(
            TransactionTextInformationViewModel(
                title: "single-transaction-request-opt-in-subtitle".localized,
                detail: viewModel?.onCompletion
            )
        )

        if let transactionAssetInformationViewModel = viewModel?.transactionAssetInformationViewModel {
            assetView.bindData(transactionAssetInformationViewModel)
        } else {
            assetView.isHidden = true
        }

        transactionIDView.bindData(
            TransactionTextInformationViewModel(
                title: viewModel?.transactionIDTitle,
                detail: viewModel?.transactionID
            )
        )

        noteView.bindData(
            TransactionTextInformationViewModel(
                title: "transaction-detail-note".localized,
                detail: viewModel?.note
            )
        )
        noteView.isHidden = (viewModel?.noteViewIsHidden).falseIfNil

        if let feeViewMode = viewModel?.fee {
            feeView.bindData(
                TransactionAmountInformationViewModel(
                    transactionViewModel: TransactionAmountViewModel(
                        feeViewMode,
                        currency: currency,
                        currencyFormatter: currencyFormatter
                    )
                )
            )
        }

        bindInnerTransactions(viewModel)
    }

    private func bindInnerTransactions(_ viewModel: AppCallTransactionDetailViewModel?) {
        guard let viewModel = viewModel,
              let innerTransactionViewModel = viewModel.innerTransactionsViewModel else {
            innerTransactionView.hideViewInStack()
            return
        }

        innerTransactionView.showViewInStack()
        innerTransactionView.bindData(innerTransactionViewModel)
    }
}

extension AppCallTransactionDetailView {
    @objc
    func notifyDelegateToOpenPeraExplorer() {
        delegate?.appCallTransactionDetailView(self, didOpen: .peraExplorer)
    }

    @objc
    func notifyDelegateToOpenInnerTransactionList() {
        delegate?.appCallTransactionDetailViewDidTapShowInnerTransactions(self)
    }

    @objc
    func notifyDelegateToOpenAssetList() {
        delegate?.appCallTransactionDetailViewDidTapShowMoreAssets(self)
    }
}

extension AppCallTransactionDetailView {
    func appCallTransactionAssetInformationViewDidTapShowMore(
        _ view: AppCallTransactionAssetInformationView
    ) {
        notifyDelegateToOpenAssetList()
    }
}

extension AppCallTransactionDetailView {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        switch interaction {
        case senderContextMenuInteraction:
            return delegate?.contextMenuInteractionForSender(in: self)
        case assetContextMenuInteraction:
            return delegate?.contextMenuInteractionForAsset(in: self)
        case applicationIDContextMenuInteraction:
            return delegate?.contextMenuInteractionForApplicationID(in: self)
        case transactionIDContextMenuInteraction:
            return delegate?.contextMenuInteractionForTransactionID(in: self)
        case noteContextMenuInteraction:
            return delegate?.contextMenuInteractionForTransactionNote(in: self)
        default:
            return nil
        }
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let view = interaction.view else {
            return nil
        }

        return UITargetedPreview(
            view: view,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let view = interaction.view else {
            return nil
        }

        return UITargetedPreview(
            view: view,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }
}

protocol AppCallTransactionDetailViewDelegate: AnyObject {
    func contextMenuInteractionForSender(
        in appCallTransactionDetailView: AppCallTransactionDetailView
    ) -> UIContextMenuConfiguration?
    func contextMenuInteractionForApplicationID(
        in appCallTransactionDetailView: AppCallTransactionDetailView
    ) -> UIContextMenuConfiguration?
    func contextMenuInteractionForAsset(
        in appCallTransactionDetailView: AppCallTransactionDetailView
    ) -> UIContextMenuConfiguration?
    func contextMenuInteractionForTransactionID(
        in appCallTransactionDetailView: AppCallTransactionDetailView
    ) -> UIContextMenuConfiguration?
    func contextMenuInteractionForTransactionNote(
        in appCallTransactionDetailView: AppCallTransactionDetailView
    ) -> UIContextMenuConfiguration?
    func appCallTransactionDetailView(
        _ transactionDetailView: AppCallTransactionDetailView,
        didOpen explorer: AlgoExplorerType
    )
    func appCallTransactionDetailViewDidTapShowInnerTransactions(
        _ transactionDetailView: AppCallTransactionDetailView
    )
    func appCallTransactionDetailViewDidTapShowMoreAssets(
        _ transactionDetailView: AppCallTransactionDetailView
    )
}
