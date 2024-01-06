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
//  Session.swift

import Foundation
import KeychainAccess
import MacaroonUtils
import MagpieCore
import UIKit
import SwiftDate

class Session: Storable {
    typealias Object = Any

    private let biometricStorageKey = "com.algorand.algorand.biometric.storage"
    private let privateStorageKey = "com.algorand.algorand.token.private"
    private let privateKey = "com.algorand.algorand.token.private.key"
    private let rewardsPrefenceKey = "com.algorand.algorand.rewards.preference"
    private let passwordKey = "pera.pinCode"
    /// <todo> Remove this key in other releases later when the v2 is accepted.
    private let termsAndServicesKey = "com.algorand.algorand.terms.services"
    private let termsAndServicesKeyV2 = "com.algorand.algorand.terms.services.v2"
    private let accountsQRTooltipKey = "com.algorand.algorand.accounts.qr.tooltip"
    private let notificationLatestTimestamp = "com.algorand.algorand.notification.latest.timestamp"
    private let currencyPreferenceKey = "com.algorand.algorand.currency.preference"
    private let userInterfacePrefenceKey = "com.algorand.algorand.interface.preference"
    private let announcementStateKey = "com.algorand.algorand.announcement.state"
    private let backupsKey = "com.algorand.algorand.secure.backups"
    private let backupPrivateKey = "com.algorand.algorand.secure.backup.privateKey"
    private let lastSeenNotificationIDKey = "com.algorand.algorand.lastseen.notification.id"
    private let hasBiometricAuthenticationKey = "com.algorand.algorand.biometric.authentication"
    
    let algorandSDK = AlgorandSDK()

    private var biometricStorage: KeychainAccess.Keychain {
        return KeychainAccess.Keychain(service: biometricStorageKey).accessibility(.whenUnlockedThisDeviceOnly, authenticationPolicy: [.biometryAny])
    }

    private var privateStorage: KeychainAccess.Keychain {
        return KeychainAccess.Keychain(service: privateStorageKey).accessibility(.whenUnlocked)
    }
    
    var authenticatedUser: User? {
        get {
            return applicationConfiguration?.authenticatedUser()
        }
        set {
            guard let userData = newValue?.encoded() else {
                return
            }
            
            if let config = applicationConfiguration {
                config.update(
                    entity: ApplicationConfiguration.entityName,
                    with: [ApplicationConfiguration.DBKeys.userData.rawValue: userData]
                )
            } else {
                ApplicationConfiguration.create(
                    entity: ApplicationConfiguration.entityName,
                    with: [ApplicationConfiguration.DBKeys.userData.rawValue: userData]
                )
            }
            
            Cache.configuration = nil
            Cache.configuration = applicationConfiguration
        }
    }
    
    var applicationConfiguration: ApplicationConfiguration? {
        get {
            if Cache.configuration == nil {
                let entityName = ApplicationConfiguration.entityName
                guard ApplicationConfiguration.hasResult(entity: entityName) else {
                    return nil
                }
                
                let result = ApplicationConfiguration.fetchAllSyncronous(entity: entityName)
                
                switch result {
                case .result(let object):
                    guard let configuration = object as? ApplicationConfiguration else {
                        return nil
                    }
                    
                    Cache.configuration = configuration
                    return Cache.configuration
                case .results(let objects):
                    guard let configuration = objects.first(where: { appConfig -> Bool in
                        if appConfig is ApplicationConfiguration {
                            return true
                        }
                        return false
                    }) as? ApplicationConfiguration else {
                        return nil
                    }
                    
                    Cache.configuration = configuration
                    return Cache.configuration
                case .error:
                    return nil
                }
            }
            return Cache.configuration
        }
        set {
            Cache.configuration = newValue
        }
    }
    
    var userInterfaceStyle: UserInterfaceStyle {
        get {
            guard let appearance = string(with: userInterfacePrefenceKey, to: .defaults),
                let appearancePreference = UserInterfaceStyle(rawValue: appearance) else {
                    return .system
            }
            return appearancePreference
        }
        set {
            self.save(newValue.rawValue, for: userInterfacePrefenceKey, to: .defaults)
        }
    }
    
    var preferredCurrencyID: CurrencyID {
        get {
            let cacheValue = string(
                with: currencyPreferenceKey,
                to: .defaults
            )
            return CurrencyID(cacheValue: cacheValue)
        }
        set {
            save(
                newValue.cacheValue,
                for: currencyPreferenceKey,
                to: .defaults
            )
        }
    }
    
    var notificationLatestFetchTimestamp: TimeInterval? {
        get {
            return userDefaults.double(forKey: notificationLatestTimestamp)
        }
        set {
            if let timestamp = newValue {
                userDefaults.set(timestamp, forKey: notificationLatestTimestamp)
            }
        }
    }

    var announcementStates: [String: AnnouncementMetadata] {
        get {
            guard let data = data(with: announcementStateKey, to: .defaults) else {
                return [:]
            }

            do {
                return try [String: AnnouncementMetadata].decoded(data, using: JSONDecodingStrategy())
            } catch {
                return [:]
            }
        }
        set {
            do {
                let data = try newValue.encoded()
                save(data, for: announcementStateKey, to: .defaults)
            } catch {
                return
            }
        }
    }

    var backups: [String: BackupMetadata] {
        get {
            guard let data = data(with: backupsKey, to: .defaults) else {
                return [:]
            }

            do {
                return try [String: BackupMetadata].decoded(data, using: JSONDecodingStrategy())
            } catch {
                return [:]
            }
        }
        set {
            do {
                /// <todo>: It may be saved as object instead of data to make it more efficient
                let data = try newValue.encoded()
                save(data, for: backupsKey, to: .defaults)
                NotificationCenter.default.post(name: .backupCreated, object: self)
            } catch {
                return
            }
        }
    }

    var lastSeenNotificationID: Int? {
        get {
            return userDefaults.integer(forKey: lastSeenNotificationIDKey)
        }
        set {
            if let notificationID = newValue {
                userDefaults.set(notificationID, forKey: lastSeenNotificationIDKey)
            }
        }
    }
    
    // isExpired is true when login needed. It will fault after 5 mins entering background
    var isValid = false

    init() {
        removeOldTermsAndServicesKeysFromDefaults()
    }
}

extension Session {
    func hasAuthentication() -> Bool {
        return authenticatedUser != nil
    }
}

extension Session {
    func savePasswordToDatabase(_ password: String) {
        if let config = applicationConfiguration {
            config.update(entity: ApplicationConfiguration.entityName, with: [ApplicationConfiguration.DBKeys.password.rawValue: password])
        } else {
            ApplicationConfiguration.create(
                entity: ApplicationConfiguration.entityName,
                with: [ApplicationConfiguration.DBKeys.password.rawValue: password]
            )
        }
    }

    func isPasswordMatchingOnDatabase(with password: String) -> Bool {
        applicationConfiguration?.password == password
    }
    
    func hasPasswordOnDatabase() -> Bool {
        applicationConfiguration?.password != nil
    }
    
    func isDefaultNodeActive() -> Bool {
        guard let config = applicationConfiguration else {
            return true
        }
        return config.isDefaultNodeActive
    }
    
    func setDefaultNodeActive(_ isActive: Bool) {
        if let config = applicationConfiguration {
            config.update(
                entity: ApplicationConfiguration.entityName,
                with: [ApplicationConfiguration.DBKeys.isDefaultNodeActive.rawValue: NSNumber(value: isActive)]
            )
        }
    }
    
    func updateName(_ name: String, for accountAddress: String) {
        guard let accountInformation = authenticatedUser?.account(address: accountAddress) else {
            return
        }
        accountInformation.updateName(name)
        authenticatedUser?.updateAccount(accountInformation)
    }
}

extension Session {
    var legacyLocalAuthenticationStatus: String? {
        return string(with: StorableKeys.localAuthenticationStatus.rawValue, to: .defaults)
    }

    func accountInformation(from address: String) -> AccountInformation? {
        return applicationConfiguration?.authenticatedUser()?.accounts.first { account -> Bool in
            account.address == address
        }
    }

    func createUser(with accounts: [AccountInformation] = []) {
        authenticatedUser = User(accounts: accounts)
    }
}

extension Session {
    func setBiometricPassword() throws {
        guard let passwordOnKeychain = privateStorage.string(for: passwordKey) else {
            throw LAError.passwordNotSet
        }

        do {
            try biometricStorage.set(passwordOnKeychain, key: passwordKey)
            // Note: To trigger Biometric Auth Dialog, we need to get it from biometric storage
            let _ = try biometricStorage.get(passwordKey)
            try setBiometricPasswordEnabled()
        } catch {
            try removeBiometricPassword()
            throw error
        }
    }

    func setBiometricPasswordSilently() throws {
        guard let passwordOnKeychain = privateStorage.string(for: passwordKey) else {
            throw LAError.passwordNotSet
        }

        do {
            try biometricStorage.set(passwordOnKeychain, key: passwordKey)
            try setBiometricPasswordEnabled()
        } catch {
            try removeBiometricPassword()
            throw error
        }
    }

    func checkBiometricPassword() throws {
        guard hasBiometricPassword() else {
            throw LAError.biometricNotSet
        }

        guard let passwordOnKeychain = privateStorage.string(for: passwordKey) else {
            throw LAError.passwordNotSet
        }

        do {
            let passwordOnBiometricStorage = try biometricStorage.get(passwordKey)
            if passwordOnKeychain != passwordOnBiometricStorage {
                throw LAError.passwordMismatch
            }
        } catch {
            throw LAError.unexpected(error)
        }
    }

    func removeBiometricPassword() throws {
        privateStorage.remove(for: hasBiometricAuthenticationKey)
        try biometricStorage.remove(passwordKey)
    }

    func hasBiometricPassword() -> Bool {
        (try? privateStorage.contains(hasBiometricAuthenticationKey)) ?? false
    }

    func setBiometricPasswordEnabled() throws {
        try privateStorage.set("ok", key: hasBiometricAuthenticationKey)
    }
}

extension Session {
    func savePrivate(_ data: Data, for account: String) {
        let dataKey = privateKey.appending(".\(account)")
        privateStorage.set(data, for: dataKey)
    }
    
    func privateData(for account: String) -> Data? {
        let dataKey = privateKey.appending(".\(account)")
        return privateStorage.data(for: dataKey)
    }
    
    func removePrivateData(for account: String) {
        let dataKey = privateKey.appending(".\(account)")
        privateStorage.remove(for: dataKey)
    }
    
    func hasPrivateData(for account: PublicKey) -> Bool {
        return privateData(for: account) != nil
    }
}

extension Session {
    func hasAlreadyCreatedBackupPrivateKey() -> Bool {
        privateDataForBackup() != nil
    }

    func privateDataForBackup() -> Data? {
        privateData(for: backupPrivateKey)
    }

    /// <note>: It overrides the existing backup mnemonics private key every time when function called.
    /// It doesn't cause any issue because this private key generated by 12-word mnemonic
    func saveBackupPrivateData(_ data: Data) {
        savePrivate(data, for: backupPrivateKey)
    }
}

/// <mark> Password Management
extension Session {
    func savePassword(_ password: String) {
        privateStorage.set(password, for: passwordKey)
    }

    func deletePassword() {
        privateStorage.remove(for: passwordKey)
    }

    func isPasswordMatching(with password: String) -> Bool {
        guard let passwordOnKeychain = privateStorage.string(for: passwordKey) else {
            return false
        }

        return password == passwordOnKeychain
    }

    func hasPassword() -> Bool {
        return privateStorage.string(for: passwordKey) != nil
    }
}

// MARK: Terms and Services
extension Session {
    /// <todo> Remove this check in other releases later when the v2 is accepted.
    private func removeOldTermsAndServicesKeysFromDefaults() {
        userDefaults.remove(for: termsAndServicesKey)
        userDefaults.remove(for: termsAndServicesKeyV2)
    }
}

extension Session {
    func setAccountQRTooltipDisplayed() {
        save(true, for: accountsQRTooltipKey, to: .defaults)
    }
    
    func isAccountQRTooltipDisplayed() -> Bool {
        return bool(with: accountsQRTooltipKey, to: .defaults)
    }
}

extension Session {
    func reset(
        includingContacts: Bool
    ) {
        authenticatedUser = nil
        applicationConfiguration = nil

        ApplicationConfiguration.clear(entity: ApplicationConfiguration.entityName)
        
        if includingContacts {
            Contact.clear(entity: Contact.entityName)
        }
        
        Node.clear(entity: Node.entityName)

        /// <todo>
        /// Why does it more than one keychain?
        privateStorage.clear()
        
        clear(.defaults)
        clear(.keychain)

        self.isValid = false
    }
}

extension Session {
    private enum Cache {
        static var configuration: ApplicationConfiguration?
    }
}
