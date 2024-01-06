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

//   ImportAccountScreen.swift

import Foundation
import MacaroonUIKit
import MacaroonUtils
import MagpieCore
import MagpieHipo
import MagpieExceptions
import UIKit

final class ImportAccountScreen: BaseViewController {
    typealias EventHandler = (Event, ImportAccountScreen) -> Void

    var eventHandler: EventHandler?

    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var loadingView = UIView()
    private lazy var imageView = ImageView()
    private lazy var titleView = Label()
    private lazy var theme = ImportAccountScreenTheme()

    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!
    )

    private let backupParameters: QRBackupParameters

    init(configuration: ViewControllerConfiguration, backupParameters: QRBackupParameters) {
        self.backupParameters = backupParameters
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()

        view.customizeAppearance(theme.background)
    }

    override func prepareLayout() {
        super.prepareLayout()
        
        addLoading()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchAccounts()
    }
    
    private func addLoading() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.centerY == 0
            $0.leading.trailing == theme.horizontalPadding
        }
        
        addImage()
        addTitle()
    }
    
    private func addImage() {
        imageView.customizeAppearance(theme.image)
        loadingView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.leading.trailing == 0
        }
    }
    
    private func addTitle() {
        titleView.customizeAppearance(theme.title)
        loadingView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == imageView.snp.bottom + theme.titleTopPadding
            $0.leading.trailing.bottom == 0
        }
    }
}

extension ImportAccountScreen {
    private func fetchAccounts() {
        api?.fetchBackupDetail(backupParameters.id) { [weak self] apiResponse in
            guard let self else { return }
            switch apiResponse {
            case .success(let encryptedBackup):
                self.decryptAccounts(from: encryptedBackup)
            case .failure(_, let model):
                self.eventHandler?(.didFailToImport(.networkFailed(model)), self)
            }
        }
    }

    private func decryptAccounts(
        from backup: Backup
    ) {
        asyncBackground {
            [weak self] in
            guard let self else { return }

            let encryptionKey = self.backupParameters.encryptionKey
            let encryptedData = self.extractEncryptedData(from: backup)
            let cryptor = Cryptor(key: encryptionKey)
            let decryptedContent = cryptor.decrypt(data: encryptedData)

            guard let decryptedData = decryptedContent.data else {
                self.publish(.didFailToImport(.decryption))
                return
            }

            do {
                let accountParameters = try [AccountImportParameters.APIModel]
                    .decoded(decryptedData)
                    .map { AccountImportParameters.init($0) }

                asyncMain {
                    self.importAccounts(from: accountParameters)
                }
            } catch {
                self.publish(.didFailToImport(.serialization(error)))
            }
        }
    }

    private func extractEncryptedData(from backup: Backup) -> Data {
        let content = backup.encryptedContent
        if let base64Data = Data(base64Encoded: content) {
            return base64Data
        } else {
            let byteArray = content.convertToByteArray(using: ",")
            return Data(bytes: byteArray)
        }
    }

    private func importAccounts(from parameters: [AccountImportParameters]) {
        guard let session, !parameters.isEmpty else {
            eventHandler?(.didFailToImport(.notImportableAccountFound), self)
            return
        }

        var importableAccounts: [AccountInformation] = []
        var unimportedAccounts: [AccountInformation] = []

        do {
            let transferAccounts = try convertAccountParametersToTransferAccounts(
                from: parameters
            )

            for transferAccount in transferAccounts {
                let accountAddress = transferAccount.accountInformation.address

                if sharedDataController.accountCollection[accountAddress] != nil {
                    unimportedAccounts.append(transferAccount.accountInformation)
                } else {
                    session.savePrivate(transferAccount.privateKey, for: accountAddress)
                    importableAccounts.append(transferAccount.accountInformation)
                }
            }
        } catch {
            eventHandler?(.didFailToImport(.invalidPrivateKey), self)
        }

        saveAccounts(importableAccounts)

        completeImporting(
            imported: importableAccounts,
            unimported: unimportedAccounts,
            parameters: parameters
        )
    }

    private func saveAccounts(_ accounts: [AccountInformation]) {
        guard let session else {
            return
        }

        let authenticatedUser = session.authenticatedUser ?? User()
        authenticatedUser.addAccounts(accounts)

        pushNotificationController.sendDeviceDetails()

        session.authenticatedUser = authenticatedUser
    }

    private func completeImporting(
        imported: [AccountInformation],
        unimported: [AccountInformation],
        parameters: [AccountImportParameters]
    ) {
        eventHandler?(
            .didCompleteImport(
                Result(
                    importedAccounts: imported.map({.init(localAccount: $0)}),
                    unimportedAccounts: unimported.map({.init(localAccount: $0)}),
                    parameters: parameters
                )
            ),
            self
        )
    }

    private func convertAccountParametersToTransferAccounts(
        from accountParameters: [AccountImportParameters]
    ) throws -> [TransferAccount] {
        var currentPreferredOrder = sharedDataController.getPreferredOrderForNewAccount()
        var transferAccounts: [TransferAccount] = []

        for accountParameter in accountParameters {
            guard let privateKey = accountParameter.privateKey else {
                continue
            }

            let accountAddress = accountParameter.address
            
            let accountInformation = AccountInformation(
                address: accountAddress,
                name: accountParameter.name ?? accountAddress.shortAddressDisplay,
                isWatchAccount: accountParameter.accountType.rawAccountType.isWatch,
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

    private func publish(
        _ event: Event
    ) {
        asyncMain { [weak self] in
            guard let self = self else { return }
            self.eventHandler?(event, self)
        }
    }
}

extension ImportAccountScreen {
    enum Event {
        case didCompleteImport(Result)
        case didFailToImport(ImportAccountScreenError)
    }

    struct Result {
        let importedAccounts: [Account]
        let unimportedAccounts: [Account]
        let parameters: [AccountImportParameters]
    }
}

enum ImportAccountScreenError: Error {
    case networkFailed(HIPAPIError?)
    case decryption
    case serialization(Error)
    case notImportableAccountFound
    case invalidPrivateKey
    case unsupportedVersion(version: String)
    case unsupportedAction
}
