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
//   TransactionTutorialViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

final class TransactionTutorialViewController: BaseScrollViewController {
    private lazy var transactionTutorialView = TransactionTutorialView()

    private let isInitialDisplay: Bool

    init(isInitialDisplay: Bool, configuration: ViewControllerConfiguration) {
        self.isInitialDisplay = isInitialDisplay
        super.init(configuration: configuration)
    }

    override func bindData() {
        super.bindData()
        transactionTutorialView.bindData(TransactionTutorialViewModel(isInitialDisplay: isInitialDisplay))
    }

    override func linkInteractors() {
        super.linkInteractors()
        transactionTutorialView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()
        addTransactionTutorialView()
    }
}

extension TransactionTutorialViewController {
    private func addTransactionTutorialView() {
        transactionTutorialView.customize(TransactionTutorialViewTheme())

        contentView.addSubview(transactionTutorialView)
        transactionTutorialView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension TransactionTutorialViewController: BottomSheetScrollPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }
}

extension TransactionTutorialViewController: TransactionTutorialViewDelegate {
    func transactionTutorialViewDidConfirmTutorial(_ transactionTutorialView: TransactionTutorialView) {
        dismissScreen()
    }

    func transactionTutorialViewDidOpenMoreInfo(_ transactionTutorialView: TransactionTutorialView) {
        open(AlgorandWeb.transactionSupport.link)
    }
}
