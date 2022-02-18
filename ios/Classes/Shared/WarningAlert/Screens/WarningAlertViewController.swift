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
//   WarningAlertViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

class WarningAlertViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    weak var delegate: WarningAlertViewControllerDelegate?
    
    private lazy var warningAlertView = WarningAlertView()
    
    private let warningAlert: WarningAlert
        
    init(warningAlert: WarningAlert, configuration: ViewControllerConfiguration) {
        self.warningAlert = warningAlert
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        warningAlertView.bind(WarningAlertViewModel(warningAlert: warningAlert))
        view.backgroundColor = Colors.Background.secondary
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        warningAlertView.delegate = self
    }
    
    override func prepareLayout() {
        prepareWholeScreenLayoutFor(warningAlertView)
    }
}

extension WarningAlertViewController: BottomSheetPresentable {
    var modalHeight: ModalHeight {
        return .preferred(380)
    }
}

extension WarningAlertViewController: WarningAlertViewDelegate {
    func warningAlertViewDidTakeAction(_ warningAlertView: WarningAlertView) {
        dismissScreen()
        delegate?.warningAlertViewControllerDidTakeAction(self)
    }
}

protocol WarningAlertViewControllerDelegate: AnyObject {
    func warningAlertViewControllerDidTakeAction(_ warningAlertViewController: WarningAlertViewController)
}
