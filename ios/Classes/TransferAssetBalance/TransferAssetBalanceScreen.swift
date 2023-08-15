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

//   TransferAssetBalanceScreen.swift

import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class TransferAssetBalanceScreen:
    ScrollScreen,
    BottomSheetScrollPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }

    private lazy var titleView = PrimaryTitleView()
    private lazy var assetIDView = SecondaryListItemView()
    private lazy var accountView = SecondaryListItemView()
    private lazy var descriptionView = Label()
    private lazy var approveActionView = MacaroonUIKit.Button()
    private lazy var closeActionView = MacaroonUIKit.Button()

    private let theme: TransferAssetBalanceScreenTheme
    private let draft: TransferAssetBalanceDraft

    typealias EventHandler = (Event) -> Void
    private let eventHandler: EventHandler

    private let copyToClipboardController: CopyToClipboardController

    init(
        theme: TransferAssetBalanceScreenTheme,
        draft: TransferAssetBalanceDraft,
        eventHandler: @escaping EventHandler,
        copyToClipboardController: CopyToClipboardController,
        api: ALGAPI?
    ) {
        self.theme = theme
        self.draft = draft
        self.eventHandler = eventHandler
        self.copyToClipboardController = copyToClipboardController

        super.init(api: api)
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        navigationItem.largeTitleDisplayMode =  .never
    }

    override func prepareLayout() {
        super.prepareLayout()

        addBackground()
        addTitle()
        addAssetID()
        addAccount()
        addDescription()
        addApproveAction()
        addCloseAction()
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]

        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }

    override func bindData() {
        super.bindData()

        let viewModel = TransferAssetBalanceViewModel(draft: draft)

        title = viewModel.title

        assetIDView.bindData(viewModel.assetID)
        accountView.bindData(viewModel.account)

        viewModel.description?.load(in: descriptionView)

        viewModel.approveAction?.load(in: approveActionView)
        viewModel.closeAction?.load(in: closeActionView)
    }
}

extension TransferAssetBalanceScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addTitle() {
        titleView.customize(theme.title)
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
        }

        let asset = draft.asset
        let viewModel = OptOutAssetNameViewModel(asset: asset)
        titleView.bindData(viewModel)
    }

    private func addAssetID() {
        assetIDView.customize(theme.assetIDView)

        let topSeparator = contentView.attachSeparator(
            theme.separator,
            to: titleView,
            margin: theme.spacingBetweenTitleAndSeparator
        )

        contentView.addSubview(assetIDView)
        assetIDView.snp.makeConstraints {
            $0.top == topSeparator.snp.bottom + theme.spacingBetweenSecondaryListItemAndSeparator
            $0.leading == 0
            $0.trailing == 0
        }

        assetIDView.startObserving(event: .didTapAccessory) {
            [weak self] in
            guard let self = self else {
                return
            }

            let assetID = self.draft.asset.id
            self.copyToClipboardController.copyID(assetID)
        }
    }

    private func addAccount() {
        accountView.customize(theme.accountView)

        let topSeparator = addSeparator(to: assetIDView)

        contentView.addSubview(accountView)
        accountView.snp.makeConstraints {
            $0.top == topSeparator.snp.bottom + theme.spacingBetweenSecondaryListItemAndSeparator
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addDescription() {
        descriptionView.customizeAppearance(theme.description)

        contentView.addSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.top == accountView.snp.bottom + theme.descriptionTopPadding
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
            $0.bottom == theme.contentEdgeInsets.bottom
        }
    }

    private func addApproveAction() {
        approveActionView.customizeAppearance(theme.approveActionView)
        approveActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)

        footerView.addSubview(approveActionView)
        approveActionView.snp.makeConstraints {
            $0.top ==  theme.actionsContentEdgeInsets.top
            $0.leading == theme.actionsContentEdgeInsets.leading
            $0.trailing == theme.actionsContentEdgeInsets.trailing
        }

        approveActionView.addTouch(
            target: self,
            action: #selector(didApprove)
        )
    }

    private func addCloseAction() {
        closeActionView.customizeAppearance(theme.closeActionView)
        closeActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)

        footerView.addSubview(closeActionView)
        closeActionView.snp.makeConstraints {
            $0.top == approveActionView.snp.bottom + theme.spacingBetweenActions
            $0.leading == theme.actionsContentEdgeInsets.leading
            $0.trailing == theme.actionsContentEdgeInsets.trailing
            $0.bottom == theme.actionsContentEdgeInsets.bottom
        }

        closeActionView.addTouch(
            target: self,
            action: #selector(didClose)
        )
    }

    private func addSeparator(
        to view: UIView
    ) -> UIView {
        return contentView.attachSeparator(
            theme.separator,
            to: view,
            margin: theme.spacingBetweenSecondaryListItemAndSeparator
        )
    }
}

extension TransferAssetBalanceScreen {
    @objc
    private func didApprove() {
        eventHandler(.performApprove)
    }

    @objc
    private func didClose() {
        eventHandler(.performClose)
    }
}

extension TransferAssetBalanceScreen {
    enum Event {
        case performApprove
        case performClose
    }
}
