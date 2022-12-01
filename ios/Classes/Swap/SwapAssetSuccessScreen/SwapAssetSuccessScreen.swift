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

//   SwapAssetSuccessScreen.swift

import MacaroonUIKit
import UIKit

final class SwapAssetSuccessScreen: BaseViewController {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var currencyFormatter = CurrencyFormatter()

    private lazy var successIconBackgroundView = UIView()
    private lazy var successIconView = UIImageView()
    private lazy var titleView = UILabel()
    private lazy var detailView = UILabel()
    private lazy var viewDetailActionView = UIButton()
    private lazy var summaryActionView = UIButton()
    private lazy var doneActionView = MacaroonUIKit.Button()

    private let swapController: SwapController
    private let theme: SwapAssetSuccessScreenTheme

    init(
        swapController: SwapController,
        theme: SwapAssetSuccessScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.swapController = swapController
        self.theme = theme
        super.init(configuration: configuration)

        isModalInPresentation = true
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        hidesCloseBarButtonItem = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setPopGestureEnabled(false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setPopGestureEnabled(true)
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeAppearance(theme.background)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addTitle()
        addSuccessIconBackground()
        addSuccessIcon()
        addDetail()
        addDoneAction()
        addSummaryAction()
        addViewDetailAction()
    }

    override func bindData() {
        super.bindData()

        guard let quote = swapController.quote else { return }

        let viewModel = SwapAssetSuccessScreenViewModel(
            quote: quote,
            parsedSwapTransactions: swapController.parsedTransactions,
            currencyFormatter: currencyFormatter
        )
        viewModel.title?.load(in: titleView)
        viewModel.detail?.load(in: detailView)
    }

    override func didTapBackBarButton() -> Bool {
        return false
    }
}

extension SwapAssetSuccessScreen {
    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        view.addSubview(titleView)
        titleView.fitToIntrinsicSize()
        titleView.snp.makeConstraints {
            $0.centerX == 0
            $0.centerY.equalToSuperview().offset(theme.titleCenterOffset)
            $0.leading == theme.titleHorizontalInset
            $0.trailing == theme.titleHorizontalInset
        }
    }

    private func addSuccessIconBackground() {
        successIconBackgroundView.customizeAppearance(theme.successIconBackground)
        successIconBackgroundView.layer.draw(corner: theme.successIconBackgroundCorner)

        view.addSubview(successIconBackgroundView)
        successIconBackgroundView.fitToIntrinsicSize()
        successIconBackgroundView.snp.makeConstraints {
            $0.fitToSize(theme.iconSize)
            $0.centerX == 0
            $0.bottom == titleView.snp.top - theme.spacingBetweenIconAndTitle
        }
    }

    private func addSuccessIcon() {
        successIconView.customizeAppearance(theme.icon)

        successIconBackgroundView.addSubview(successIconView)
        successIconView.fitToIntrinsicSize()
        successIconView.snp.makeConstraints {
            $0.center == 0
        }
    }

    private func addDetail() {
        detailView.customizeAppearance(theme.detail)

        view.addSubview(detailView)
        detailView.fitToIntrinsicSize()
        detailView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndDetail
            $0.leading == theme.detailHorizontalInset
            $0.trailing == theme.detailHorizontalInset
        }
    }

    private func addDoneAction() {
        doneActionView.customizeAppearance(theme.doneAction)
        doneActionView.contentEdgeInsets = UIEdgeInsets(theme.doneActionContentEdgeInsets)

        view.addSubview(doneActionView)
        doneActionView.snp.makeConstraints {
            $0.leading == theme.doneActionEdgeInsets.leading
            $0.trailing == theme.doneActionEdgeInsets.trailing

            let bottomInset =
                view.compactSafeAreaInsets.bottom +
                (navigationController ?? self).additionalSafeAreaInsets.bottom
                + theme.doneActionEdgeInsets.bottom
            $0.bottom == bottomInset
        }

        doneActionView.addTouch(
            target: self,
            action: #selector(didTapDoneAction)
        )
    }

    private func addSummaryAction() {
        summaryActionView.customizeAppearance(theme.summaryAction)

        view.addSubview(summaryActionView)
        summaryActionView.fitToIntrinsicSize()
        summaryActionView.snp.makeConstraints {
            $0.leading == theme.summaryActionHorizontalInset
            $0.bottom == doneActionView.snp.top - theme.spacingBetweenSummaryActionAndDoneAction
            $0.trailing <= theme.summaryActionHorizontalInset
        }

        summaryActionView.addTouch(
            target: self,
            action: #selector(didTapSummaryAction)
        )
    }

    private func addViewDetailAction() {
        viewDetailActionView.customizeAppearance(theme.viewDetailAction)

        let bottomSeparator = view.attachSeparator(
            theme.separator,
            to: summaryActionView,
            margin: theme.spacingBetweenSeparatorAndSummaryAction
        )

        view.addSubview(viewDetailActionView)
        viewDetailActionView.fitToIntrinsicSize()
        viewDetailActionView.snp.makeConstraints {
            $0.top >= detailView.snp.bottom + theme.minimumSpacingBetweenViewDetailActionAndDetail
            $0.leading == theme.viewDetailActionHorizontalInset
            $0.bottom == bottomSeparator.snp.top - theme.spacingBetweenViewDetailActionAndSummaryAction
            $0.trailing <= theme.viewDetailActionHorizontalInset
        }

        viewDetailActionView.addTouch(
            target: self,
            action: #selector(didTapViewDetailAction)
        )
    }
}

extension SwapAssetSuccessScreen {
    @objc
    private func didTapViewDetailAction() {
        eventHandler?(.didTapViewDetailAction)
    }

    @objc
    private func didTapDoneAction() {
        eventHandler?(.didTapDoneAction)
    }

    @objc
    private func didTapSummaryAction() {
        eventHandler?(.didTapSummaryAction)
    }
}

extension SwapAssetSuccessScreen {
    private func setPopGestureEnabled(_ isEnabled: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
    }
}

extension SwapAssetSuccessScreen {
    enum Event {
        case didTapViewDetailAction
        case didTapDoneAction
        case didTapSummaryAction
    }
}
