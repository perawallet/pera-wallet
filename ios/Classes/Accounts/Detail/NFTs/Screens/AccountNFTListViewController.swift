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
//   AccountNFTListViewController.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AccountNFTListViewController: BaseViewController {
    
    private let account: Account

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }

    private lazy var noContentView = NoContentView()

    override func prepareLayout() {
        super.prepareLayout()
        addNoContentView()
    }

    override func bindData() {
        super.bindData()
        bindNoContentViewData()
    }
}

extension AccountNFTListViewController {
    private func addNoContentView() {
        noContentView.customize(NoContentViewCommonTheme())

        view.addSubview(noContentView)
        noContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func bindNoContentViewData() {
        noContentView.bindData(AccountNFTListNoContentViewModel())
    }
}
