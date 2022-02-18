// Copyright 2019 Algorand, Inc.

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
//  LedgerTroubleshootBluetoothViewController.swift

import UIKit
import SafariServices

class LedgerTroubleshootBluetoothViewController: BaseScrollViewController {
    
    private lazy var ledgerTroubleshootBluetoothView = LedgerTroubleshootBluetoothView()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Component.separator
        return view
    }()
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "title-step-1".localized
        view.backgroundColor = Colors.Background.tertiary
        contentView.backgroundColor = Colors.Background.tertiary
        scrollView.backgroundColor = Colors.Background.tertiary
        setNavigationBarTertiaryBackgroundColor()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerTroubleshootBluetoothView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupSeparatorView()
        setupLedgerTroubleshootBluetoothView()
    }
}

extension LedgerTroubleshootBluetoothViewController {
    private func setupSeparatorView() {
        view.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { maker in
            maker.top.equalTo(scrollView.snp.top)
            maker.leading.trailing.equalToSuperview()
            maker.height.equalTo(1.0)
        }
    }
    
    private func setupLedgerTroubleshootBluetoothView() {
        contentView.addSubview(ledgerTroubleshootBluetoothView)
        
        ledgerTroubleshootBluetoothView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerTroubleshootBluetoothViewController: LedgerTroubleshootBluetoothViewDelegate {
    func ledgerTroubleshootBluetoothView(_ view: LedgerTroubleshootBluetoothView, didTapUrl url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}
