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
//   LedgerPairWarningViewController.swift

import Foundation
import MacaroonUIKit
import MacaroonBottomSheet

final class LedgerPairWarningViewController: BaseScrollViewController {
    weak var delegate: LedgerPairWarningViewControllerDelegate?
    
    private lazy var ledgerPairWarningView = LedgerPairWarningView()

    override func prepareLayout() {
        super.prepareLayout()
        addLedgerPairWarningView()
    }
}

extension LedgerPairWarningViewController {
    private func addLedgerPairWarningView() {
        ledgerPairWarningView.customize(LedgerPairWarningViewTheme())

        contentView.addSubview(ledgerPairWarningView)
        ledgerPairWarningView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        ledgerPairWarningView.startObserving(event: .close) {
            [weak self] in
            guard let self = self else { return }
            self.dismissScreen()
            self.delegate?.ledgerPairWarningViewControllerDidTakeAction(self)
        }
    }
}

extension LedgerPairWarningViewController: BottomSheetScrollPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }
}

protocol LedgerPairWarningViewControllerDelegate: AnyObject {
    func ledgerPairWarningViewControllerDidTakeAction(
        _ ledgerPairWarningViewController: LedgerPairWarningViewController
    )
}
