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

//   SwapSummaryScreen.swift

import MacaroonUIKit
import UIKit

final class SwapSummaryScreen: ScrollScreen {
    private lazy var receivedInfoView = SwapSummaryItemView()
    private lazy var paidInfoView = SwapSummaryItemView()
    private lazy var statusInfoView = SwapSummaryStatusView()
    private lazy var accountInfoView = SwapSummaryAccountView()
    private lazy var feeContextView = VStackView()
    private lazy var algorandFeeInfoView = SwapSummaryItemView()
    private lazy var optInFeeInfoView = SwapSummaryItemView()
    private lazy var exchangeFeeInfoView = SwapSummaryItemView()
    private lazy var peraFeeInfoView = SwapSummaryItemView()
    private lazy var priceImpactInfoView = SwapSummaryItemView()

    private lazy var currencyFormatter = CurrencyFormatter()

    private let swapController: SwapController
    private let theme: SwapSummaryScreenTheme

    init(
        swapController: SwapController,
        theme: SwapSummaryScreenTheme = .init(),
        api: ALGAPI?
    ) {
        self.swapController = swapController
        self.theme = theme
        
        super.init(api: api)
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()
        navigationItem.largeTitleDisplayMode =  .never
    }

    override func prepareLayout() {
        super.prepareLayout()
        addBackground()
        addReceivedInfo()
        addPaidInfo()
        addStatusInfo()
        addAccountInfo()
        addFeeContext()
        addPriceImpactInfo()
    }

    override func bindData() {
        super.bindData()

        title = "swap-confirm-summary-title".localized

        let viewModel = SwapSummaryScreenViewModel(
            account: swapController.account,
            quote: swapController.quote!,
            parsedTransactions: swapController.parsedTransactions,
            currencyFormatter: currencyFormatter
        )

        receivedInfoView.bindData(viewModel.receivedInfo)
        paidInfoView.bindData(viewModel.paidInfo)
        statusInfoView.bindData(viewModel.statusInfo)
        accountInfoView.bindData(viewModel.accountInfo)
        algorandFeeInfoView.bindData(viewModel.algorandFeeInfo)

        if let optInFeeInfo = viewModel.optInFeeInfo {
            optInFeeInfoView.bindData(optInFeeInfo)
        } else {
            optInFeeInfoView.hideViewInStack()
        }

        exchangeFeeInfoView.bindData(viewModel.exchangeFeeInfo)
        peraFeeInfoView.bindData(viewModel.peraFeeInfo)
        priceImpactInfoView.bindData(viewModel.priceImpactInfo)
    }
}

extension SwapSummaryScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addReceivedInfo() {
        receivedInfoView.customize(theme.summaryItem)

        contentView.addSubview(receivedInfoView)
        receivedInfoView.snp.makeConstraints {
            $0.top == theme.topSpacing
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset
        }
    }

    private func addPaidInfo() {
        paidInfoView.customize(theme.summaryItem)

        contentView.addSubview(paidInfoView)
        paidInfoView.snp.makeConstraints {
            $0.top == receivedInfoView.snp.bottom + theme.itemVerticalSpacing
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset
        }
    }

    private func addStatusInfo() {
        statusInfoView.customize(theme.summaryStatus)

        contentView.addSubview(statusInfoView)
        statusInfoView.snp.makeConstraints {
            $0.top == paidInfoView.snp.bottom + theme.itemVerticalSpacing
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset
        }
    }

    private func addAccountInfo() {
        accountInfoView.customize(theme.summaryAccount)

        let topSeparator = addSeparator(to: statusInfoView)

        contentView.addSubview(accountInfoView)
        accountInfoView.snp.makeConstraints {
            $0.top == topSeparator.snp.bottom + theme.separatorSpacing
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset
        }
    }

    private func addFeeContext() {
        let topSeparator = addSeparator(to: accountInfoView)

        contentView.addSubview(feeContextView)
        feeContextView.spacing = theme.itemVerticalSpacing
        feeContextView.snp.makeConstraints {
            $0.top == topSeparator.snp.bottom + theme.separatorSpacing
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset
        }

        addAlgorandFeeInfo()
        addOptInFeeInfo()
        addExchangeFeeInfo()
        addPeraFeeInfo()
    }

    private func addAlgorandFeeInfo() {
        algorandFeeInfoView.customize(theme.summaryItem)
        feeContextView.addArrangedSubview(algorandFeeInfoView)
    }

    private func addOptInFeeInfo() {
        optInFeeInfoView.customize(theme.summaryItem)
        feeContextView.addArrangedSubview(optInFeeInfoView)
    }

    private func addExchangeFeeInfo() {
        exchangeFeeInfoView.customize(theme.summaryItem)
        feeContextView.addArrangedSubview(exchangeFeeInfoView)
    }

    private func addPeraFeeInfo() {
        peraFeeInfoView.customize(theme.summaryItem)
        feeContextView.addArrangedSubview(peraFeeInfoView)
    }

    private func addPriceImpactInfo() {
        priceImpactInfoView.customize(theme.summaryItem)

        let topSeparator = addSeparator(to: feeContextView)

        contentView.addSubview(priceImpactInfoView)
        priceImpactInfoView.snp.makeConstraints {
            $0.top == topSeparator.snp.bottom + theme.separatorSpacing
            $0.leading == theme.horizontalInset
            $0.trailing == theme.horizontalInset
            $0.bottom <= theme.minimumBottomSpacing
        }
    }

    private func addSeparator(
        to view: UIView
    ) -> UIView {
        return contentView.attachSeparator(
            theme.separator,
            to: view,
            margin: theme.separatorSpacing
        )
    }
}
