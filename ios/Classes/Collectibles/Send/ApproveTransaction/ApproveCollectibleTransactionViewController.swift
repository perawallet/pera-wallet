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

//   ApproveCollectibleTransactionViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class ApproveCollectibleTransactionViewController:
    BaseScrollViewController,
    BottomSheetScrollPresentable {

    var eventHandler: ((ApproveCollectibleTransactionViewControllerEvent) -> Void)?

    private lazy var bottomTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var contextView = UIView()
    private lazy var titleView = Label()
    private lazy var descriptionView = Label()
    private lazy var senderAccountInfoView = CollectibleTransactionInfoView()
    private lazy var toAccountInfoView = CollectibleTransactionInfoView()
    private lazy var transactionFeeInfoView = CollectibleTransactionInfoView()

    private lazy var optOutContentView = MacaroonUIKit.BaseView()
    private lazy var optOutCheckboxView = MacaroonUIKit.Button()
    private lazy var optOutTitleView = Label()
    private lazy var optOutInfoActionView = MacaroonUIKit.Button()

    private lazy var confirmActionViewIndicator = ViewLoadingIndicator()
    private lazy var confirmActionView = MacaroonUIKit.LoadingButton(
        loadingIndicator: confirmActionViewIndicator
    )

    private lazy var cancelActionView = MacaroonUIKit.Button()

    private let draft: SendCollectibleDraft
    private let viewModel: ApproveCollectibleTransactionViewModel
    private let theme: ApproveCollectibleTransactionViewControllerTheme

    // Asset creators cannot opt out from their assets.
    private var isSenderAssetCreator: Bool {
        return draft.fromAccount.address == draft.collectibleAsset.creator?.address
    }

    init(
        draft: SendCollectibleDraft,
        theme: ApproveCollectibleTransactionViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        self.viewModel = ApproveCollectibleTransactionViewModel(
            draft,
            currencyFormatter: CurrencyFormatter()
        )
        self.theme = theme

        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        build()
        bind()
    }

    private func build() {
        addBackground()
        addContent()
    }

    private func bind() {
        senderAccountInfoView.bindData(viewModel.senderAccountViewModel)
        toAccountInfoView.bindData(viewModel.toAccountViewModel)
        transactionFeeInfoView.bindData(viewModel.transactionFeeViewModel)
    }

    override func linkInteractors() {
        optOutInfoActionView.addTouch(target: self, action: #selector(didTapOptOutInfo))
        optOutCheckboxView.addTouch(target: self, action: #selector(didTapOptOutCheckbox))

        cancelActionView.addTouch(target: self, action: #selector(didTapCancel))
        confirmActionView.addTouch(target: self, action: #selector(didTapConfirm))
    }
}

extension ApproveCollectibleTransactionViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContent() {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contentEdgeInsets.top
            $0.leading == theme.contentEdgeInsets.leading
            $0.trailing == theme.contentEdgeInsets.trailing
            $0.bottom <= theme.contentEdgeInsets.bottom
        }

        addTitle()
        addDescription()
        addSenderAccount()
        addToAccount()
        addTransactionFee()
        addOptOutContent()
        addConfirmAction()
        addCancelAction()
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        contextView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == 0
        }
    }

    private func addDescription() {
        descriptionView.customizeAppearance(theme.description)

        contextView.addSubview(descriptionView)
        descriptionView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == titleView.snp.bottom + theme.descriptionTopMargin
        }
    }

    private func addSenderAccount() {
        senderAccountInfoView.customize(theme.info)

        contextView.addSubview(senderAccountInfoView)

        let topSeparator = addSeparator(
            to: descriptionView,
            margin: theme.spacingBetweenDescriptionAndSeparator
        )

        senderAccountInfoView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == topSeparator.snp.top
        }
    }

    private func addToAccount() {
        toAccountInfoView.customize(theme.info)

        contextView.addSubview(toAccountInfoView)
        toAccountInfoView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == senderAccountInfoView.snp.bottom
        }
    }

    private func addTransactionFee() {
        transactionFeeInfoView.customize(theme.info)

        contextView.addSubview(transactionFeeInfoView)
        transactionFeeInfoView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == toAccountInfoView.snp.bottom
        }
    }

    private func addOptOutContent() {
        if isSenderAssetCreator {
            optOutCheckboxView.isSelected = false
            return
        }

        contextView.addSubview(optOutContentView)
        optOutContentView.snp.makeConstraints {
            $0.top == transactionFeeInfoView.snp.bottom + theme.spacingBetweenInfoAndSeparator
            $0.leading == 0
            $0.trailing == 0
        }

        addOptOutCheckbox()
        addOptOutTitle()
        addOptOutInfoAction()
    }

    private func addOptOutCheckbox() {
        optOutCheckboxView.customizeAppearance(theme.optOutCheckbox)

        optOutContentView.addSubview(optOutCheckboxView)
        optOutCheckboxView.fitToHorizontalIntrinsicSize()
        optOutCheckboxView.snp.makeConstraints {
            $0.leading == 0
            $0.centerY == 0
        }

        optOutCheckboxView.isSelected = true
    }

    private func addOptOutTitle() {
        optOutTitleView.customizeAppearance(theme.optOutTitle)

        optOutContentView.addSubview(optOutTitleView)
        optOutTitleView.snp.makeConstraints {
            $0.leading == optOutCheckboxView.snp.trailing + theme.optOutTitleLeadingMargin
            $0.centerY == optOutCheckboxView
            $0.top == 0
            $0.bottom == 0
        }
    }

    private func addOptOutInfoAction() {
        optOutInfoActionView.customizeAppearance(theme.optOutInfo)

        optOutContentView.addSubview(optOutInfoActionView)
        optOutInfoActionView.fitToHorizontalIntrinsicSize()
        optOutInfoActionView.snp.makeConstraints {
            $0.trailing == 0
            $0.leading >= optOutTitleView.snp.trailing + theme.minimumHorizontalSpacing
            $0.centerY == optOutTitleView
        }
    }

    private func addConfirmAction() {
        let topView = isSenderAssetCreator ? transactionFeeInfoView : optOutContentView

        confirmActionViewIndicator.applyStyle(theme.confirmActionIndicator)

        confirmActionView.customizeAppearance(theme.confirmAction)
        confirmActionView.draw(corner: theme.actionCorner)

        contextView.addSubview(confirmActionView)
        confirmActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        confirmActionView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.fitToHeight(theme.confirmActionHeight)
            $0.top == topView.snp.bottom + theme.confirmActionViewTopPadding
        }
    }

    private func addCancelAction() {
        cancelActionView.customizeAppearance(theme.cancelAction)
        cancelActionView.draw(corner: theme.actionCorner)

        contextView.addSubview(cancelActionView)
        cancelActionView.contentEdgeInsets = UIEdgeInsets(theme.actionContentEdgeInsets)
        cancelActionView.snp.makeConstraints {
            $0.leading == 0
            $0.trailing == 0
            $0.top == confirmActionView.snp.bottom + theme.spacingBetweenActions
            $0.bottom == 0
        }
    }

    private func addSeparator(
        to view: UIView,
        margin: LayoutMetric
    ) -> UIView {
        return contextView.attachSeparator(
            theme.separator,
            to: view,
            margin: margin
        )
    }
}

extension ApproveCollectibleTransactionViewController {
    @objc
    private func didTapOptOutCheckbox(_ button: UIButton) {
        button.isSelected.toggle()
    }

    @objc
    private func didTapOptOutInfo() {
        openOptOutInformation()
    }

    @objc
    private func didTapConfirm() {
        startLoading()

        if optOutCheckboxView.isSelected {
            eventHandler?(.approvedSendAndOptOut)
            return
        }

        eventHandler?(.approvedSend)
    }

    @objc
    private func didTapCancel() {
        eventHandler?(.cancelledSend)
    }

    private func openOptOutInformation() {
        let configurator = BottomWarningViewConfigurator(
            image: "icon-info-green".uiImage,
            title: "collectible-opt-out-info-title".localized,
            description: .plain("collectible-opt-out-info-description".localized),
            secondaryActionButtonTitle: "title-close".localized
        )

        bottomTransition.perform(
            .bottomWarning(
                configurator: configurator
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension ApproveCollectibleTransactionViewController {
    func startLoading() {
        confirmActionView.startLoading()
    }

    func stopLoading() {
        confirmActionView.stopLoading()
    }
}

enum ApproveCollectibleTransactionViewControllerEvent {
    case approvedSend
    case approvedSendAndOptOut
    case cancelledSend
}
