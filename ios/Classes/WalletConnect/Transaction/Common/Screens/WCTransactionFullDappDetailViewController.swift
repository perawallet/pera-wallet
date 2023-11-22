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
//   WCTransactionFullDappDetailViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

final class WCTransactionFullDappDetailViewController: BaseViewController {
    private let viewConfigurator: WCTransactionFullDappDetailConfigurator

    init(_ viewModel: WCTransactionFullDappDetailConfigurator, configuration: ViewControllerConfiguration) {
        self.viewConfigurator = viewModel
        super.init(configuration: configuration)
    }

    private lazy var theme = Theme()
    private lazy var detailView = WCTransactionFullDappDetailView()

    override func configureAppearance() {
        super.configureAppearance()

        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func setListeners() {
        detailView.delegate = self
    }

    override func prepareLayout() {
        detailView.customize(theme.detailViewTheme)
        prepareWholeScreenLayoutFor(detailView)
    }

    override func bindData() {
        detailView.bindData(viewConfigurator)
    }
}

extension WCTransactionFullDappDetailViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }
}

extension WCTransactionFullDappDetailViewController: WCTransactionFullDappDetailViewDelegate {

    func wcTransactionFullDappDetailViewDidTapPrimaryActionButton(
        _ view: WCTransactionFullDappDetailView
    ) {
        viewConfigurator.primaryAction?()
        dismissScreen()
    }
}
