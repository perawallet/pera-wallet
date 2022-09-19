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
//  LedgerApprovalViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

final class LedgerApprovalViewController: BaseViewController {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private lazy var ledgerApprovalView = LedgerApprovalView()
    private lazy var theme = Theme()

    private let mode: Mode
    private let deviceName: String

    init(mode: Mode, deviceName: String, configuration: ViewControllerConfiguration) {
        self.mode = mode
        self.deviceName = deviceName
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        hidesCloseBarButtonItem = true
    }

    override func configureAppearance() {
        customizeBackground()
    }

    private func customizeBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func setListeners() {
        ledgerApprovalView.setListeners()
        ledgerApprovalView.delegate = self
    }
    
    override func prepareLayout() {
        ledgerApprovalView.customize(theme.ledgerApprovalViewTheme)

        view.addSubview(ledgerApprovalView)
        ledgerApprovalView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func bindData() {
        ledgerApprovalView.bindData(LedgerApprovalViewModel(mode: mode, deviceName: deviceName))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ledgerApprovalView.startConnectionAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ledgerApprovalView.stopConnectionAnimation()
    }
}

extension LedgerApprovalViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .preferred(theme.modalHeight)
    }
}

extension LedgerApprovalViewController: LedgerApprovalViewDelegate {
    func ledgerApprovalViewDidTapCancelButton(_ ledgerApprovalView: LedgerApprovalView) {
        eventHandler?(.didCancel)
    }
}

extension LedgerApprovalViewController {
    enum Mode {
        case connection
        case approve
    }
}

extension LedgerApprovalViewController {
    enum Event {
        case didCancel
    }
}
