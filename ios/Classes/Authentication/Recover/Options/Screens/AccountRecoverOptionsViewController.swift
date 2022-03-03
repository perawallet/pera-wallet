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
//   AccountRecoverOptionsViewController.swift

import UIKit
import MacaroonBottomSheet
import MacaroonUIKit

final class AccountRecoverOptionsViewController:
    BaseScrollViewController,
    BottomSheetPresentable {
    weak var delegate: AccountRecoverOptionsViewControllerDelegate?

    private lazy var contextView = VStackView()

    private let theme: AccountRecoverOptionsViewControllerTheme
    
    init(
        configuration: ViewControllerConfiguration,
        theme: AccountRecoverOptionsViewControllerTheme = .init()
    ) {
        self.theme = theme
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }
    
    private func build() {
        addBackground()
        addContext()
        addActions()
    }
}

extension AccountRecoverOptionsViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }
    
    private func addContext() {
        contentView.addSubview(contextView)
        contextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.contentPaddings.top,
            leading: theme.contentPaddings.leading,
            bottom: theme.contentPaddings.bottom,
            trailing: theme.contentPaddings.trailing
        )
        contextView.isLayoutMarginsRelativeArrangement = true
        contextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
    
    private func addActions() {
        addPastePassphraseAction()
        addScanQRAction()
        addLearnAction()
    }
    
    private func addPastePassphraseAction() {
        addAction(
            PasteFullPassphraseListActionViewModel(),
            #selector(pasteFullPassphrase)
        )
    }
    
    private func addScanQRAction() {
        addAction(
            ScanQRCodeListActionViewModel(),
            #selector(scanQRCode)
        )
    }
    
    private func addLearnAction() {
        addAction(
            LearnMoreListActionViewModel(),
            #selector(learnMore)
        )
    }
    
    private func addAction(
        _ viewModel: ListActionViewModel,
        _ selector: Selector
    ) {
        let actionView = ListActionView()
        
        actionView.customize(theme.action)
        actionView.bindData(viewModel)
        
        contextView.addArrangedSubview(actionView)
        
        actionView.addTouch(
            target: self,
            action: selector
        )
    }
}

extension AccountRecoverOptionsViewController {
    @objc
    private func pasteFullPassphrase() {
        dismissScreen()
        delegate?.accountRecoverOptionsViewControllerDidPasteFromClipboard(self)
    }
    
    @objc
    private func scanQRCode() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.accountRecoverOptionsViewControllerDidOpenScanQR(self)
        }
    }
    
    @objc
    private func learnMore() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.accountRecoverOptionsViewControllerDidOpenMoreInfo(self)
        }
    }
}

protocol AccountRecoverOptionsViewControllerDelegate: AnyObject {
    func accountRecoverOptionsViewControllerDidOpenScanQR(
        _ viewController: AccountRecoverOptionsViewController
    )
    func accountRecoverOptionsViewControllerDidPasteFromClipboard(
        _ viewController: AccountRecoverOptionsViewController
    )
    func accountRecoverOptionsViewControllerDidOpenMoreInfo(
        _ viewController: AccountRecoverOptionsViewController
    )
}
