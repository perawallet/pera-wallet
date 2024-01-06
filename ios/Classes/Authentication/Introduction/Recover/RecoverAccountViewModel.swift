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

//   RecoverAccountViewModel.swift

import Foundation
import MacaroonUIKit

struct RecoverAccountViewModel: ViewModel {
    private(set) var recoverWithPassphraseViewModel: AccountTypeViewModel?
    private(set) var importFromSecureBackupViewModel: AccountTypeViewModel?
    private(set) var recoverWithQRViewModel: AccountTypeViewModel?
    private(set) var recoverWithLedgerViewModel: AccountTypeViewModel?
    private(set) var importFromWebViewModel: AccountTypeViewModel?

    init() {
        bind()
    }
}

extension RecoverAccountViewModel {
    private mutating func bind() {
        bindRecoverWithPassphraseViewModel()
        bindImportFromSecureBackupViewModel()
        bindRecoverWithQRViewModel()
        bindRecoverWithLedgerViewModel()
        bindImportFromWebViewModel()
    }

    private mutating func bindRecoverWithPassphraseViewModel() {
        recoverWithPassphraseViewModel = AccountTypeViewModel(.recover(type: .passphrase))
    }
    
    private mutating func bindRecoverWithQRViewModel() {
        recoverWithQRViewModel = AccountTypeViewModel(.recover(type: .qr))
    }

    private mutating func bindImportFromSecureBackupViewModel() {
        importFromSecureBackupViewModel = AccountTypeViewModel(.recover(type: .importFromSecureBackup))
    }

    private mutating func bindRecoverWithLedgerViewModel() {
        recoverWithLedgerViewModel = AccountTypeViewModel(.recover(type: .ledger))
    }

    private mutating func bindImportFromWebViewModel() {
        importFromWebViewModel = AccountTypeViewModel(.recover(type: .importFromWeb))
    }
}
