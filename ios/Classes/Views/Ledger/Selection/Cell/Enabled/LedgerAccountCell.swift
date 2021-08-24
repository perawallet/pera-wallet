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
//  LedgerAccountCell.swift

import UIKit

class LedgerAccountCell: BaseCollectionViewCell<LedgerAccountView> {
    
    weak var delegate: LedgerAccountCellDelegate?
    
    override func linkInteractors() {
        super.linkInteractors()
        contextView.delegate = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.clear()
    }
}

extension LedgerAccountCell {
    func bind(_ viewModel: LedgerAccountViewModel) {
        contextView.bind(viewModel)
    }
    
    func bind(_ viewModel: LedgerAccountNameViewModel) {
        contextView.bind(viewModel)
    }
}

extension LedgerAccountCell: LedgerAccountViewDelegate {
    func ledgerAccountViewDidOpenMoreInfo(_ ledgerAccountView: LedgerAccountView) {
        delegate?.ledgerAccountCellDidOpenMoreInfo(self)
    }
}

protocol LedgerAccountCellDelegate: AnyObject {
    func ledgerAccountCellDidOpenMoreInfo(_ ledgerAccountCell: LedgerAccountCell)
}
