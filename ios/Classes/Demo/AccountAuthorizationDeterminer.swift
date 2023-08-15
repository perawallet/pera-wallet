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

//   AccountAuthorizationDeterminer.swift

final class AccountAuthorizationDeterminer {
    private unowned let session: Session

    init(session: Session) {
        self.session = session
    }
}

extension AccountAuthorizationDeterminer {
    func determineAccountAuthorization(
        of account: Account,
        with accountCollection: AccountCollection
    ) -> AccountAuthorization {
        if account.isWatchAccount {
            return .watch
        }

        if let accountHandle = accountCollection[account.address],
           !accountHandle.isAvailable {
            return .unknown
        }

        if account.hasAuthAccount() {
            return determineAccountAuthorizationForRekeyedAccount(
                account: account,
                accountCollection: accountCollection
            )
        }

        if account.hasLedgerDetail() {
            return .ledger
        }

        let isStandard = session.hasPrivateData(for: account.address)
        if isStandard {
            return .standard
        }

        return .noAuthInLocal
    }
}

extension AccountAuthorizationDeterminer {
    private func determineAccountAuthorizationForRekeyedAccount(
        account: Account,
        accountCollection: AccountCollection
    ) -> AccountAuthorization {
        let isRekeyedToLedgerAccountInLocal = isRekeyedToLedgerAccountInLocal(
            account: account,
            accountCollection: accountCollection
        )
        if isRekeyedToLedgerAccountInLocal {
            return determineAccountAuthorizationForRekeyedToLedgerAccount(account)
        }

        let isRekeyedToStandardAccountInLocal = isRekeyedToStandardAccountInLocal(
            account: account,
            accountCollection: accountCollection
        )
        if isRekeyedToStandardAccountInLocal {
            return determineAccountAuthorizationForRekeyedToStandardAccount(account)
        }

        return determineAccountAuthorizationForRekeyedToNoAuthInLocalAccount(account)
    }

    private func determineAccountAuthorizationForRekeyedToLedgerAccount(_ account: Account) -> AccountAuthorization {
        let hasPrivateData = session.hasPrivateData(for: account.address)
        if hasPrivateData { return .standardToLedgerRekeyed }

        let hasLedgerDetail = account.hasLedgerDetail()
        if hasLedgerDetail { return .ledgerToLedgerRekeyed }

        return .unknownToLedgerRekeyed
    }

    private func determineAccountAuthorizationForRekeyedToStandardAccount(_ account: Account) -> AccountAuthorization {
        let hasPrivateData = session.hasPrivateData(for: account.address)
        if hasPrivateData { return .standardToStandardRekeyed }

        let hasLedgerDetail = account.hasLedgerDetail()
        if hasLedgerDetail { return .ledgerToStandardRekeyed }

        return .unknownToStandardRekeyed
    }

    private func determineAccountAuthorizationForRekeyedToNoAuthInLocalAccount(_ account: Account) -> AccountAuthorization {
        let hasPrivateData = session.hasPrivateData(for: account.address)
        if hasPrivateData { return .standardToNoAuthInLocalRekeyed }

        let hasLedgerDetail = account.hasLedgerDetail()
        if hasLedgerDetail { return .ledgerToNoAuthInLocalRekeyed }

        return .unknownToNoAuthInLocalRekeyed
    }
    
    private func isRekeyedToLedgerAccountInLocal(
        account: Account,
        accountCollection: AccountCollection
    ) -> Bool {
        updateLedgerDetailOfRekeyedAccountIfNeeded(
            account: account,
            accountCollection: accountCollection
        )

        let hasRekeyDetail = account.rekeyDetail?[safe: account.authAddress] != nil
        return hasRekeyDetail
    }

    private func updateLedgerDetailOfRekeyedAccountIfNeeded(
        account: Account,
        accountCollection: AccountCollection
    ) {
        guard let authAddress = account.authAddress,
              let authAccount = accountCollection[authAddress],
              let ledgerDetail = authAccount.value.ledgerDetail,
              account.rekeyDetail?[safe: authAddress] == nil else {
            return

        }

        account.addRekeyDetail(
            ledgerDetail,
            for: authAddress
        )
        session.authenticatedUser?.updateLocalAccount(account)
    }

    private func isRekeyedToStandardAccountInLocal(
        account: Account,
        accountCollection: AccountCollection
    ) -> Bool {
        guard let authAddress = account.authAddress else { return false }
        guard let authAccount = accountCollection[authAddress] else { return false }

        return session.hasPrivateData(for: authAccount.value.address)
    }
}
