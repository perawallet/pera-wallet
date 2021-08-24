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
//  AlgoExplorerLabel.swift

import UIKit

class AlgoExplorerLabel: UILabel {
    
    weak var delegate: AlgoExplorerLabelDelegate?
    
    override public var canBecomeFirstResponder: Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInteractions()
        setupMenuItems()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copyText) ||
            action == #selector(notifyDelegateToOpenAlgoExplorer) ||
            action == #selector(notifyDelegateToOpenGoalSeeker)
    }
}

extension AlgoExplorerLabel {
    private func setupInteractions() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMenuController)))
    }

    private func setupMenuItems() {
        let copyItem = UIMenuItem(title: "title-copy".localized, action: #selector(copyText))
        let algoExplorerItem = UIMenuItem(
            title: "transaction-id-open-algoexplorer".localized,
            action: #selector(notifyDelegateToOpenAlgoExplorer)
        )
        let goalSeekerItem = UIMenuItem(
            title: "transaction-id-open-goalseeker".localized,
            action: #selector(notifyDelegateToOpenGoalSeeker)
        )
        UIMenuController.shared.menuItems = [copyItem, algoExplorerItem, goalSeekerItem]
    }
}

extension AlgoExplorerLabel {
    @objc
    private func showMenuController() {
        if let superView = superview {
            let menuController = UIMenuController.shared
            menuController.setTargetRect(frame, in: superView)
            menuController.setMenuVisible(true, animated: true)
            becomeFirstResponder()
        }
    }
    
    @objc
    private func copyText() {
        UIPasteboard.general.string = text
    }

    @objc
    private func notifyDelegateToOpenAlgoExplorer() {
        delegate?.algoExplorerLabel(self, didOpen: .algoexplorer)
    }

    @objc
    private func notifyDelegateToOpenGoalSeeker() {
        delegate?.algoExplorerLabel(self, didOpen: .goalseeker)
    }
}

protocol AlgoExplorerLabelDelegate: AnyObject {
    func algoExplorerLabel(_ algoExplorerLabel: AlgoExplorerLabel, didOpen explorer: AlgoExplorerType)
}

enum AlgoExplorerType {
    case algoexplorer
    case goalseeker

    func transactionURL(with id: String, in network: AlgorandAPI.BaseNetwork) -> URL? {
        switch network {
        case .testnet:
            return testNetTransactionURL(with: id)
        case .mainnet:
            return mainNetTransactionURL(with: id)
        }
    }

    private func testNetTransactionURL(with id: String) -> URL? {
        switch self {
        case .algoexplorer:
            return URL(string: "https://testnet.algoexplorer.io/tx/\(id)")
        case .goalseeker:
            return URL(string: "https://goalseeker.purestake.io/algorand/testnet/transaction/\(id)")
        }
    }

    private func mainNetTransactionURL(with id: String) -> URL? {
        switch self {
        case .algoexplorer:
            return URL(string: "https://algoexplorer.io/tx/\(id)")
        case .goalseeker:
            return URL(string: "https://goalseeker.purestake.io/algorand/mainnet/transaction/\(id)")
        }
    }
}
