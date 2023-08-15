// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RekeyedAccountSelectionListAccountCell.swift

import Foundation
import UIKit
import MacaroonUIKit

final class RekeyedAccountSelectionListAccountCell:
    CollectionCell<LedgerAccountCellView>,
    ViewModelBindable,
    LedgerAccountViewDelegate,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .info: TargetActionInteraction()
    ]
    
    var accessory: RekeyedAccountSelectionListAccountItemAccessory = .unselected {
        didSet { updateAccessoryIfNeeded(old: oldValue) }
    }

    static let theme = RekeyedAccountSelectionListAccountCellTheme()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contextView.customize(Self.theme.context)

        contextView.delegate = self
    }
}

extension RekeyedAccountSelectionListAccountCell {
    private func updateAccessoryIfNeeded(old: RekeyedAccountSelectionListAccountItemAccessory) {
        if accessory != old {
            updateAccessory()
        }
    }

    private func updateAccessory() {
        let isSelected = accessory == .selected
        contextView.isSelected = isSelected
    }
}

extension RekeyedAccountSelectionListAccountCell {
    func ledgerAccountViewDidOpenMoreInfo(_ ledgerAccountView: LedgerAccountCellView) {
        publishInfoAction()
    }
}

extension RekeyedAccountSelectionListAccountCell {
    private func publishInfoAction() {
        let infoInteraction = uiInteractions[.info]
        infoInteraction?.publish()
    }
}

extension RekeyedAccountSelectionListAccountCell {
    enum Event {
        case info
    }
}
