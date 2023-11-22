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

//   BuySellOptionsScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class BuySellOptionsScreen:
    BaseScrollViewController,
    BottomSheetScrollPresentable {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var contextView = UIView()
    private lazy var buyContextHeaderView = UILabel()
    private lazy var buyContextView = MacaroonUIKit.VStackView()
    private lazy var sellContextHeaderView = UILabel()
    private lazy var sellContextView = MacaroonUIKit.VStackView()

    private let theme: BuySellOptionsScreenTheme

    init(
        theme: BuySellOptionsScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.theme = theme
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    private func addUI() {
        addBackground()
        addContext()
    }
}

extension BuySellOptionsScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextPaddings.top
            $0.leading == theme.contextPaddings.leading
            $0.bottom == theme.contextPaddings.bottom
            $0.trailing == theme.contextPaddings.trailing
        }

        addBuyContextHeader()
        addBuyContext()
        addSellContextHeader()
        addSellContext()
    }
}

extension BuySellOptionsScreen {
    private func addBuyContextHeader() {
        buyContextHeaderView.customizeAppearance(theme.buyContextHeader)

        contextView.addSubview(buyContextHeaderView)
        buyContextHeaderView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addBuyContext() {
        contextView.addSubview(buyContextView)
        buyContextView.spacing = theme.spacingBetweenOptions
        buyContextView.snp.makeConstraints {
            $0.top == buyContextHeaderView.snp.bottom + theme.spacingBetweenBuyContextHeaderAndBuyContext
            $0.leading == 0
            $0.trailing == 0
        }

        addBuyOptionsIfPossible()
    }

    private func addBuyOptionsIfPossible() {
        /// <note> Buy options are temporarily disabled. Date: 20.11.2023
        addBuyOptionsNotAvailableContent()

        // addBuyWithTransakOption()
    }

    private func addBuyOptionsNotAvailableContent() {
        let contentView = UILabel()
        contentView.customizeAppearance(theme.buyOptionsNotAvailable)
       
        buyContextView.addArrangedSubview(contentView)
    }

    private func addBuyAlgoWithSardineOption() {
        addOption(
            viewModel: BuyAlgoWithSardineOptionViewModel(),
            selector: #selector(performBuyAlgoWithSardine),
            to: buyContextView
        )
    }

    private func addBuyWithTransakOption() {
        addOption(
            viewModel: BuyWithTransakOptionViewModel(),
            selector: #selector(performBuyWithTransak),
            to: buyContextView
        )
    }
}

extension BuySellOptionsScreen {
    @objc
    private func performBuyAlgoWithSardine() {
        eventHandler?(.performBuyAlgoWithSardine)
    }

    @objc
    private func performBuyWithTransak() {
        eventHandler?(.performBuyWithTransak)
    }
}

extension BuySellOptionsScreen {
    private func addSellContextHeader() {
        sellContextHeaderView.customizeAppearance(theme.sellContextHeader)

        contextView.addSubview(sellContextHeaderView)
        sellContextHeaderView.snp.makeConstraints {
            $0.top == buyContextView.snp.bottom + theme.spacingBetweenBuyAndSellContext
            $0.leading == 0
            $0.trailing == 0
        }
    }
    
    private func addSellContext() {
        contextView.addSubview(sellContextView)
        sellContextView.spacing = theme.spacingBetweenOptions
        sellContextView.snp.makeConstraints {
            $0.top == sellContextHeaderView.snp.bottom + theme.spacingBetweenSellContextHeaderAndSellContext
            $0.leading == 0
            $0.trailing == 0
            $0.bottom == 0
        }

        addSellOptions()
    }

    private func addSellOptions() {
        addBuyGiftCardWithBidaliOption()
    }

    private func addBuyGiftCardWithBidaliOption() {
        addOption(
            viewModel: BuyGiftCardsWithBidaliOptionViewModel(),
            selector: #selector(performBuyGiftCardsWithBidali),
            to: sellContextView
        )
    }
}

extension BuySellOptionsScreen {
    @objc
    private func performBuyGiftCardsWithBidali() {
        eventHandler?(.performBuyGiftCardsWithBidali)
    }
 }

extension BuySellOptionsScreen {
    private func addOption(
        viewModel: ListItemButtonViewModel,
        selector: Selector,
        to context: UIStackView
    ) {
        let view = ListItemButton()
        view.customize(theme.option)
        view.bindData(viewModel)

        context.addArrangedSubview(view)

        view.addTouch(
            target: self,
            action: selector
        )
    }
}

 extension BuySellOptionsScreen {
     enum Event {
         case performBuyAlgoWithSardine
         case performBuyWithTransak
         case performBuyGiftCardsWithBidali
     }
 }
