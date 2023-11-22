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

//   WCSingleArbitraryDataRequestScreen.swift

import Foundation
import UIKit
import MacaroonUIKit

final class WCSingleArbitraryDataRequestScreen: BaseViewController {
    weak var delegate: WCSingleArbitraryDataRequestScreenDelegate?

    private lazy var theme = Theme()

    private lazy var scrollView = UIScrollView()
    private lazy var requestView = WCSingleTransactionRequestView()

    private lazy var viewModel: WCSingleTransactionRequestViewModel? = {
        guard let data = data else {
            return nil
        }

        let account: Account?

        if let address = data.signer {
            account = sharedDataController.accountCollection[address]?.value
        } else {
            account = nil
        }

        return WCSingleTransactionRequestViewModel(
            data: data,
            account: account,
            currency: sharedDataController.currency,
            currencyFormatter: currencyFormatter
        )
    }()

    private var data: WCArbitraryData? {
        return dataSource.data(at: 0)
    }

    private let dataSource: WCMainArbitraryDataDataSource
    private let currencyFormatter: CurrencyFormatter

    init(
        dataSource: WCMainArbitraryDataDataSource,
        currencyFormatter: CurrencyFormatter,
        configuration: ViewControllerConfiguration
    ) {
        self.dataSource = dataSource
        self.currencyFormatter = currencyFormatter

        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = theme.backgroundColor.uiColor
        scrollView.backgroundColor = theme.backgroundColor.uiColor
        requestView.backgroundColor = theme.backgroundColor.uiColor

        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }

    override func linkInteractors() {
        super.linkInteractors()

        requestView.delegate = self
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        title = viewModel?.title

        hidesCloseBarButtonItem = true
    }

    override func prepareLayout() {
        super.prepareLayout()

        addScrollView()
        addContentView()
    }

    override func bindData() {
        super.bindData()

        requestView.bind(viewModel)
    }
}

extension WCSingleArbitraryDataRequestScreen {
    private func addScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }

    private func addContentView() {
        let contentView = UIView()
        contentView.backgroundColor = theme.backgroundColor.uiColor

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.height.equalToSuperview().priority(.low)
            make.edges.equalToSuperview()
        }

        contentView.addSubview(requestView)
        requestView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension WCSingleArbitraryDataRequestScreen: WCSingleTransactionRequestViewDelegate {
    func wcSingleTransactionRequestViewDidTapCancel(
        _ requestView: WCSingleTransactionRequestView
    ) {
        delegate?.wcSingleArbitraryDataRequestScreenDidReject(self)
    }

    func wcSingleTransactionRequestViewDidTapConfirm(
        _ requestView: WCSingleTransactionRequestView
    ) {
        delegate?.wcSingleArbitraryDataRequestScreenDidConfirm(self)
    }

    func wcSingleTransactionRequestViewDidTapShowTransaction(
        _ requestView: WCSingleTransactionRequestView
    ) {
        guard let data else { return }

        open(
            .wcArbitraryDataScreen(
                data: data,
                wcSession: dataSource.wcSession
            ),
            by: .push
        )
    }

    func wcSingleTransactionRequestViewDidOpenASADiscovery(
        _ requestView: WCSingleTransactionRequestView
    ) { }
}

protocol WCSingleArbitraryDataRequestScreenDelegate: AnyObject {
    func wcSingleArbitraryDataRequestScreenDidConfirm(
        _ wcSingleArbitraryDataRequestScreen: WCSingleArbitraryDataRequestScreen
    )
    func wcSingleArbitraryDataRequestScreenDidReject(
        _ wcSingleArbitraryDataRequestScreen: WCSingleArbitraryDataRequestScreen
    )
}
