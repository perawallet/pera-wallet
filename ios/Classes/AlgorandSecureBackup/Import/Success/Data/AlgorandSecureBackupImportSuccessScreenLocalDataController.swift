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

//   AlgorandSecureBackupImportSuccessScreenLocalDataController.swift

import Foundation

final class AlgorandSecureBackupImportSuccessScreenLocalDataController:
    WebImportSuccessScreenLocalDataController {

    init(
        configuration: ViewControllerConfiguration,
        accountImportParameters: [AccountImportParameters],
        selectedAccounts: [Account]
    ) {
        let result = Self.createResult(
            configuration: configuration,
            accountImportParameters: accountImportParameters,
            selectedAccounts: selectedAccounts
        )
        super.init(result: result)
    }

    override func createHeaderItem(importedAccountCount: Int) -> [WebImportSuccessListViewItem] {
        return [.asbHeader(.init(importedAccountCount: importedAccountCount))]
    }

    override func createMissingAccountItem(
        unimportedAccountCount: Int,
        unsupportedAccountCount: Int
    ) -> [WebImportSuccessListViewItem] {
        return [
            .asbMissingAccounts(
                .init(
                    unimportedAccountCount: unimportedAccountCount,
                    unsupportedAccountCount: unsupportedAccountCount
                )
            )
        ]
    }

    private static func createResult(
        configuration: ViewControllerConfiguration,
        accountImportParameters: [AccountImportParameters],
        selectedAccounts: [Account]
    ) -> ImportAccountScreen.Result {
        var accountsDictionary: [String: AccountImportParameters] = [:]

        accountImportParameters.forEach { accountParameter in
            accountsDictionary[accountParameter.address] = accountParameter
        }

        let filteredAccounts = selectedAccounts.compactMap { account in
            return accountsDictionary[account.address]
        }

        let transferAccounts = convertAccountParametersToTransferAccounts(
            accountParameters: filteredAccounts,
            configuration: configuration
        )

        let importConfiguration = self.saveTransferAccounts(
            accountParameters: accountImportParameters,
            transferAccounts: transferAccounts,
            configuration: configuration
        )

        return importConfiguration
    }


    private static func convertAccountParametersToTransferAccounts(
        accountParameters: [AccountImportParameters],
        configuration: ViewControllerConfiguration
    ) -> [TransferAccount] {
        let sharedDataController = configuration.sharedDataController

        var currentPreferredOrder = sharedDataController.getPreferredOrderForNewAccount()
        var transferAccounts: [TransferAccount] = []
        let algorandSDK = AlgorandSDK()

        for accountParameter in accountParameters where accountParameter.isImportable(using: algorandSDK) {
            guard let privateKey = accountParameter.privateKey else {
                continue
            }

            let accountAddress = accountParameter.address

            let accountInformation = AccountInformation(
                address: accountAddress,
                name: accountParameter.name ?? accountAddress.shortAddressDisplay,
                isWatchAccount: false,
                preferredOrder: currentPreferredOrder,
                isBackedUp: true
            )
            transferAccounts.append(
                TransferAccount(
                    privateKey: privateKey,
                    accountInformation: accountInformation
                )
            )
            currentPreferredOrder = currentPreferredOrder.advanced(by: 1)
        }

        return transferAccounts
    }

    private static func saveTransferAccounts(
        accountParameters: [AccountImportParameters],
        transferAccounts: [TransferAccount],
        configuration: ViewControllerConfiguration
    ) -> ImportAccountScreen.Result {
        let session = configuration.session
        let sharedDataController = configuration.sharedDataController

        guard let session, !transferAccounts.isEmpty else {
            return ImportAccountScreen.Result(
                importedAccounts: [],
                unimportedAccounts: [],
                parameters: accountParameters
            )
        }

        var importableAccounts: [AccountInformation] = []
        var unimportedAccounts: [AccountInformation] = []

        for transferAccount in transferAccounts {
            let accountAddress = transferAccount.accountInformation.address

            if sharedDataController.accountCollection[accountAddress] != nil {
                unimportedAccounts.append(transferAccount.accountInformation)
            } else {
                session.savePrivate(transferAccount.privateKey, for: accountAddress)
                importableAccounts.append(transferAccount.accountInformation)
            }
        }

        saveAccounts(accounts: importableAccounts, configuration: configuration)

        return ImportAccountScreen.Result(
            importedAccounts: importableAccounts.map { .init(localAccount: $0) },
            unimportedAccounts: unimportedAccounts.map { .init(localAccount: $0) },
            parameters: accountParameters
        )
    }

    private static func saveAccounts(
        accounts: [AccountInformation],
        configuration: ViewControllerConfiguration
    ) {
        guard let session = configuration.session, !accounts.isEmpty else {
            return
        }

        let pushNotificationController = PushNotificationController(
            target: ALGAppTarget.current,
            session: configuration.session!,
            api: configuration.api!
        )

        let authenticatedUser = session.authenticatedUser ?? User()
        authenticatedUser.addAccounts(accounts)

        pushNotificationController.sendDeviceDetails()

        session.authenticatedUser = authenticatedUser
    }
}
