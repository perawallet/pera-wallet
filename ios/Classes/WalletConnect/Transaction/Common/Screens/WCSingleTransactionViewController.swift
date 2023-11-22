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
//   WCSingleTransactionViewController.swift

import UIKit
import MagpieCore

class WCSingleTransactionViewController: BaseScrollViewController {
    private let layout = Layout<LayoutConstants>()

    var transactionView: WCSingleTransactionView? {
        return nil
    }

    private lazy var dappMessageModalTransition = BottomSheetTransition(presentingViewController: self)

    private(set) var transaction: WCTransaction
    private(set) var account: Account?
    private(set) var transactionRequest: WalletConnectRequestDraft
    private let wcSession: WCSessionDraft?

    init(
        transaction: WCTransaction,
        transactionRequest: WalletConnectRequestDraft,
        session: WCSessionDraft,
        configuration: ViewControllerConfiguration
    ) {
        self.transaction = transaction
        self.transactionRequest = transactionRequest
        self.wcSession = session
        if let address = transaction.transactionDetail?.sender {
            self.account = configuration.sharedDataController.accountCollection[address]?.value
        }
        super.init(configuration: configuration)                                                      
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.backgroundColor = Colors.Defaults.background.uiColor
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupTransactionViewLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.post(
            name: .SingleTransactionHeaderUpdate,
            object: transaction
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.post(
            name: .SingleTransactionHeaderUpdate,
            object: nil
        )
    }
}

extension WCSingleTransactionViewController {
    private func setupTransactionViewLayout() {
        guard let transactionView = transactionView else {
            return
        }

        contentView.addSubview(transactionView)

        transactionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension WCSingleTransactionViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 36.0
        let bottomInset: CGFloat = 40.0
    }
}
