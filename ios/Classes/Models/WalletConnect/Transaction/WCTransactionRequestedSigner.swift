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

//   WCTransactionRequestedSigner.swift

import Foundation

final class WCTransactionRequestedSigner {
    /// <note>
    /// Address will be set if the transaction request that is sent to the device must be signed with this address.
    var address: PublicKey?
    /// <note>
    /// Account will be set if the transaction request that is sent to the device exists in the wallet.
    var account: Account?

    /// <note>
    /// Checks if the received signer address is set but the wallet does not contain that account.
    var containsSignerInTheWallet: Bool {
        return account != nil && address != nil
    }

    func findSignerAccount(
        in accountCollection: AccountCollection,
        on session: Session,
        transactionDetail: WCTransactionDetail?,
        authAddress: String?,
        signer: WCTransaction.Signer
    ) {
        if let authAddress = authAddress {
            address = authAddress
            account = findAccount(
                transactionAuthAddress: authAddress,
                in: accountCollection,
                on: session
            )
            return
        }

        switch signer {
        case .sender:
            if let sender = transactionDetail?.sender {
                address = sender
                account = findAccount(
                    sender,
                    in: accountCollection,
                    on: session
                )
                return
            }
        case let .current(address):
            if let address = address {
                self.address = address
                account = findAccount(
                    address,
                    in: accountCollection,
                    on: session
                )
                return
            }
        case .multisig:
            break
        case .unsignable:
            break
        }
    }

    private func findAccount(
        _ address: String? = nil,
        transactionAuthAddress: String? = nil,
        in accountCollection: AccountCollection,
        on session: Session
    ) -> Account? {
        if let transactionAuthAddress {
            guard let account = accountCollection.account(for: transactionAuthAddress) else {
                return nil
            }

            if account.hasLedgerDetail() {
                return account
            }

            if session.privateData(for: transactionAuthAddress) != nil {
                return account
            }

            return nil
        }

        guard let address,
              let account = accountCollection.account(for: address),
              account.authorization.isAuthorized else {
            return nil
        }
        
        if account.authorization.isLedger {
            return account
        }

        if account.authorization.isRekeyed {
            return findRekeyedAccount(for: account, among: accountCollection)
        }
        
        if session.privateData(for: address) != nil {
            return account
        }

        return nil
    }

    private func findRekeyedAccount(for account: Account, among accountCollection: AccountCollection) -> Account? {
        guard let authAddress = account.authAddress else {
            return nil
        }

        if account.rekeyDetail?[authAddress] != nil {
            return account
        } else {
            guard let authAccount = accountCollection[authAddress]?.value else {
                return nil
            }
            
            if let ledgerDetail = authAccount.ledgerDetail {
                account.addRekeyDetail(ledgerDetail, for: authAddress)
            }
            
            return account
        }
    }
}

/// <note> Arbitrary Data
extension WCTransactionRequestedSigner {
    func findSignerAccount(
        signer: String,
        in accountCollection: AccountCollection,
        on session: Session
    ) {
        self.address = signer
        self.account = findAccount(
            signer: signer,
            in: accountCollection,
            on: session
        )
    }

    private func findAccount(
        signer: String,
        in accountCollection: AccountCollection,
        on session: Session
    ) -> Account? {
        guard let account = accountCollection.account(for: signer) else {
            return nil
        }

        if account.hasLedgerDetail() {
            return account
        }

        if session.privateData(for: signer) != nil {
            return account
        }

        return nil
    }
}
