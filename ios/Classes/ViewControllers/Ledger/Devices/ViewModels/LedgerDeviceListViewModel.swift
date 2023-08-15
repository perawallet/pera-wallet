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
//  LedgerDeviceListViewModel.swift

import MacaroonUIKit
import CoreBluetooth

final class LedgerDeviceListViewModel: PairedViewModel {
    private(set) var ledgerName: TextProvider?

    init(_ model: CBPeripheral) {
        bindLedgerName(model)
    }
}

extension LedgerDeviceListViewModel {
    private func bindLedgerName(_ peripheral: CBPeripheral) {
        self.ledgerName = peripheral.name?.bodyRegular(lineBreakMode: .byTruncatingTail)
    }
}
