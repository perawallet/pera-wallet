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
//  TransactionHistoryHeaderSupplementaryView.swift

import UIKit

class TransactionHistoryHeaderSupplementaryView: BaseSupplementaryView<TransactionHistoryHeaderView> {
    
    weak var delegate: TransactionHistoryHeaderSupplementaryViewDelegate?
    
    override func linkInteractors() {
        contextView.delegate = self
    }

    func bind(_ viewModel: TransactionHistoryHeaderViewModel) {
        contextView.bind(viewModel)
    }
}

extension TransactionHistoryHeaderSupplementaryView: TransactionHistoryHeaderViewDelegate {
    func transactionHistoryHeaderViewDidOpenFilterOptions(_ transactionHistoryHeaderView: TransactionHistoryHeaderView) {
        delegate?.transactionHistoryHeaderSupplementaryViewDidOpenFilterOptions(self)
    }
    
    func transactionHistoryHeaderViewDidShareHistory(_ transactionHistoryHeaderView: TransactionHistoryHeaderView) {
        delegate?.transactionHistoryHeaderSupplementaryViewDidShareHistory(self)
    }
}

protocol TransactionHistoryHeaderSupplementaryViewDelegate: class {
    func transactionHistoryHeaderSupplementaryViewDidOpenFilterOptions(
        _ transactionHistoryHeaderSupplementaryView: TransactionHistoryHeaderSupplementaryView
    )
    func transactionHistoryHeaderSupplementaryViewDidShareHistory(
        _ transactionHistoryHeaderSupplementaryView: TransactionHistoryHeaderSupplementaryView
    )
}
