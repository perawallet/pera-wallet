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

//   MoonPayTransactionViewController.swift

import Foundation
import MacaroonBottomSheet
import MacaroonUIKit

final class MoonPayTransactionViewController: BaseViewController {
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var transactionView = MoonPayTransactionView()
    
    private lazy var dataController =  MoonPayTransactionDataController(
        sharedDataController: sharedDataController,
        accountAddress: moonPayParams.address
    )
    private let moonPayParams: MoonPayParams
    
    init(moonPayParams: MoonPayParams, configuration: ViewControllerConfiguration) {
        self.moonPayParams = moonPayParams
        super.init(configuration: configuration)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        dataController.delegate = self

        transactionView.startObserving(event: .close) { [weak self] in
            self?.dismissScreen()
        }
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        view.customizeBaseAppearance(backgroundColor: Colors.Defaults.background)
        addTransactionView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataController.loadData()
    }
}

extension MoonPayTransactionViewController {
    private func addTransactionView() {
        transactionView.customize(MoonPayTransactionViewTheme())
        
        view.addSubview(transactionView)
        transactionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension MoonPayTransactionViewController: MoonPayTransactionDataControllerDelegate {
    func moonPayTransactionDataControllerDidLoad(
        _ dataController: MoonPayTransactionDataController,
        account: Account
    ) {
        transactionView.bindData(
            MoonPayTransactionViewModel(
                status: moonPayParams.transactionStatus,
                account: account
            )
        )
    }
}

extension MoonPayTransactionViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }
}
