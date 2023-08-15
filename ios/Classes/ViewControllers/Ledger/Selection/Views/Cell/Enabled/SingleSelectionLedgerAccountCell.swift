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

//  SingleSelectionLedgerAccountCell.swift

import UIKit

final class SingleSelectionLedgerAccountCell: LedgerAccountCell {
    override var isSelected: Bool {
        didSet {
            contextView.isSelected = isSelected
        }
    }

    weak var delegate: SingleSelectionLedgerAccountCellDelegate?

    static let theme: LedgerAccountCellViewTheme = {
        var theme = LedgerAccountCellViewTheme()
        theme.configureForSingleSelection()
        return theme
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contextView.customize(Self.theme)

        contextView.delegate = self
    }
}

extension SingleSelectionLedgerAccountCell {
    func bind(_ viewModel: LedgerAccountViewModel) {
        contextView.bindData(viewModel)
    }
}

extension SingleSelectionLedgerAccountCell: LedgerAccountViewDelegate {
    func ledgerAccountViewDidOpenMoreInfo(_ ledgerAccountView: LedgerAccountCellView) {
        delegate?.singleSelectionLedgerAccountCellDidOpenMoreInfo(self)
    }
}

protocol SingleSelectionLedgerAccountCellDelegate: AnyObject {
    func singleSelectionLedgerAccountCellDidOpenMoreInfo(_ ledgerAccountCell: SingleSelectionLedgerAccountCell)
}
