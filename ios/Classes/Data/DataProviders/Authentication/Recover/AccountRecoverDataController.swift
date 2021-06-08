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
//   AccountRecoverDataController.swift

import Foundation

class AccountRecoverDataController: NSObject {

    weak var delegate: AccountRecoverDataControllerDelegate?

    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func recoverAccount(from mnemonics: String) {
        guard let privateKey = getPrivateKey(from: mnemonics),
            let address = getAddress(from: privateKey),
            let account = composeAccount(with: address) else {
            return
        }

        addRecoveredAccount(account, with: privateKey)
        delegate?.accountRecoverDataController(self, didRecover: account)
    }

    private func getPrivateKey(from mnemonics: String) -> Data? {
        guard let privateKey = session.privateKey(forMnemonics: mnemonics) else {
            delegate?.accountRecoverDataController(self, didFailRecoveringWith: .invalid)
            return nil
        }

        return privateKey
    }

    private func getAddress(from privateKey: Data) -> String? {
        guard let address = session.address(fromPrivateKey: privateKey) else {
            delegate?.accountRecoverDataController(self, didFailRecoveringWith: .sdk)
            return nil
        }

        return address
    }

    private func composeAccount(with address: String) -> AccountInformation? {
        if let sameAccount = session.account(from: address) {
            // If the recovered account is rekeyed or watch account in the app, save the passphrase.
            // Convert the account type to standard account if it's a watch account since the account has the passphrase now.
            if sameAccount.isRekeyed() || sameAccount.isWatchAccount() {
                return AccountInformation(
                    address: address,
                    name: sameAccount.name ?? address.shortAddressDisplay(),
                    type: sameAccount.isWatchAccount() ? .standard : sameAccount.type,
                    ledgerDetail: sameAccount.ledgerDetail,
                    rekeyDetail: sameAccount.rekeyDetail
                )
            } else {
                delegate?.accountRecoverDataController(self, didFailRecoveringWith: .alreadyExist)
                return nil
            }
        } else {
            return AccountInformation(address: address, name: address.shortAddressDisplay(), type: .standard)
        }
    }

    private func addRecoveredAccount(_ account: AccountInformation, with privateKey: Data) {
        session.savePrivate(privateKey, for: account.address)

        let user: User

        if let authenticatedUser = session.authenticatedUser {
            user = authenticatedUser

            if session.authenticatedUser?.account(address: account.address) != nil {
                user.updateAccount(account)
            } else {
                user.addAccount(account)
            }
        } else {
            user = User(accounts: [account])
        }

        session.addAccount(Account(accountInformation: account))
        session.authenticatedUser = user
    }
}

extension AccountRecoverDataController {
    enum RecoverError: Error {
        case invalid
        case sdk
        case alreadyExist
    }
}

protocol AccountRecoverDataControllerDelegate: class {
    func accountRecoverDataController(_ accountRecoverDataController: AccountRecoverDataController, didRecover account: AccountInformation)
    func accountRecoverDataController(
        _ accountRecoverDataController: AccountRecoverDataController,
        didFailRecoveringWith error: AccountRecoverDataController.RecoverError
    )
}
