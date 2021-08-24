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
//  SendTransactionViewController.swift

import UIKit
import Magpie
import SVProgressHUD

protocol SendTransactionViewControllerDelegate: AnyObject {
    func sendTransactionViewController(_ viewController: SendTransactionViewController, didCompleteTransactionFor asset: Int64?)
}

class SendTransactionViewController: BaseViewController {
    
    weak var delegate: SendTransactionViewControllerDelegate?
    
    private(set) lazy var sendTransactionView = SendTransactionView()
    
    private let assetReceiverState: AssetReceiverState
    private(set) var isSenderEditable: Bool
    private(set) var transactionController: TransactionController
    var fee: Int64?
    
    var transactionData: Data?
    
    init(
        assetReceiverState: AssetReceiverState,
        transactionController: TransactionController,
        isSenderEditable: Bool,
        configuration: ViewControllerConfiguration
    ) {
        self.assetReceiverState = assetReceiverState
        self.transactionController = transactionController
        self.isSenderEditable = isSenderEditable
        super.init(configuration: configuration)
    }
    
    override func linkInteractors() {
        sendTransactionView.transactionDelegate = self
        transactionController.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupSendTransactionViewLayout()
    }
    
    func completeTransaction(with id: TransactionID) { }
}

extension SendTransactionViewController {
    private func setupSendTransactionViewLayout() {
        view.addSubview(sendTransactionView)
        
        sendTransactionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension SendTransactionViewController: SendTransactionViewDelegate {
    func sendTransactionViewDidTapSendButton(_ sendTransactionView: SendTransactionView) {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        transactionController.uploadTransaction()
    }
}

extension SendTransactionViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID) {
        SVProgressHUD.dismiss()
        completeTransaction(with: id)
        
        if isSenderEditable {
            dismissScreen()
            return
        }
        
        navigateBack()
    }
    
    private func navigateBack() {
        guard let navigationController = self.navigationController else {
            return
        }
        
        var viewControllers = navigationController.viewControllers
        viewControllers.removeLast(2)
        self.navigationController?.setViewControllers(viewControllers, animated: false)
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPError<TransactionError>) {
        SVProgressHUD.dismiss()
        switch error {
        case let .network(apiError):
            switch apiError {
            case .connection:
                displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
            default:
                NotificationBanner.showError("title-error".localized, message: apiError.debugDescription)
            }
        default:
            NotificationBanner.showError("title-error".localized, message: error.localizedDescription)
        }
    }
}
