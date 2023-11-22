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

//   WCArbitraryDataViewController.swift

import UIKit

final class WCArbitraryDataViewController: BaseScrollViewController {
    private let layout = Layout<LayoutConstants>()

    private lazy var currencyFormatter = CurrencyFormatter()

    private lazy var contextView = WCArbitraryDataView()

    private lazy var dappMessageModalTransition = BottomSheetTransition(presentingViewController: self)

    private let data: WCArbitraryData
    private let wcSession: WCSessionDraft
    private let account: Account?

    init(
        data: WCArbitraryData,
        wcSession: WCSessionDraft,
        configuration: ViewControllerConfiguration
    ) {
        self.data = data
        self.wcSession = wcSession

        if let address = data.signer {
            self.account = configuration.sharedDataController.accountCollection[address]?.value
        } else {
            self.account = nil
        }

        super.init(configuration: configuration)
    }

    override func prepareLayout() {
        super.prepareLayout()

        addUI()
    }

    override func configureAppearance() {
        super.configureAppearance()

        title = "wallet-connect-arbitrary-data-details-title".localized

        view.backgroundColor = Colors.Defaults.background.uiColor
    }

    override func bindData() {
        let viewModel = WCArbitraryDataViewModel(
            wcSession: wcSession,
            data: data,
            senderAccount: account,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
        contextView.bind(viewModel)
    }
}

extension WCArbitraryDataViewController {
    private func addUI() {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension WCArbitraryDataViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 36.0
        let bottomInset: CGFloat = 40.0
    }
}
