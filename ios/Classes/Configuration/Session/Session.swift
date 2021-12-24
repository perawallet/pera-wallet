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
//  Session.swift

import Magpie
import KeychainAccess

class Session: Storable {
    typealias Object = Any
    
    private let privateStorageKey = "com.algorand.algorand.token.private"
    private let privateKey = "com.algorand.algorand.token.private.key"
    private let rewardsPrefenceKey = "com.algorand.algorand.rewards.preference"
    /// <todo> Remove this key in other releases later when the v2 is accepted.
    private let termsAndServicesKey = "com.algorand.algorand.terms.services"
    private let termsAndServicesKeyV2 = "com.algorand.algorand.terms.services.v2"
    private let accountsQRTooltipKey = "com.algorand.algorand.accounts.qr.tooltip"
    private let notificationLatestTimestamp = "com.algorand.algorand.notification.latest.timestamp"
    private let currencyPreferenceKey = "com.algorand.algorand.currency.preference"
    private let userInterfacePrefenceKey = "com.algorand.algorand.interface.preference"
    
    let algorandSDK = AlgorandSDK()
    
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
            NotificationCenter.default.post(name: .AuthenticatedUserUpdate, object: self, userInfo: nil)
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
    
    var rewardDisplayPreference: RewardPreference {
        get {
            guard let rewardPreference = string(with: rewardsPrefenceKey, to: .defaults),
                let rewardDisplayPreference = RewardPreference(rawValue: rewardPreference) else {
                    return .allowed
            }
            return rewardDisplayPreference
        }
        set {
            self.save(newValue.rawValue, for: rewardsPrefenceKey, to: .defaults)
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
    
    var preferredCurrency: String {
        get {
            return string(with: currencyPreferenceKey, to: .defaults) ?? "USD"
        }
        set {
            save(newValue, for: currencyPreferenceKey, to: .defaults)
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
    
    // isExpired is true when login needed. It will fault after 5 mins entering background
    var isValid = false
    
    var verifiedAssets: [VerifiedAsset]?
    
    var assetDetails: [Int64: AssetDetail] = [:]
    
    var accounts = [Account]()
    
    init() {
        removeOldTermsAndServicesKeysFromDefaults()
    }
}

extension Session {
    enum RewardPreference: String {
        case allowed = "allowed"
        case disabled = "disabled"
    }
}

extension Session {
    func savePassword(_ password: String) {
        if let config = applicationConfiguration {
            config.update(entity: ApplicationConfiguration.entityName, with: [ApplicationConfiguration.DBKeys.password.rawValue: password])
        } else {
            ApplicationConfiguration.create(
                entity: ApplicationConfiguration.entityName,
                with: [ApplicationConfiguration.DBKeys.password.rawValue: password]
            )
        }
    }
    
    func isPasswordMatching(with password: String) -> Bool {
        guard let config = applicationConfiguration else {
            return false
        }
        return config.password == password
    }
    
    func hasPassword() -> Bool {
        guard let config = applicationConfiguration else {
            return false
        }
        return config.password != nil
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
        
        guard let account = account(from: accountAddress),
            let index = index(of: account) else {
            return
        }
        
        account.name = name
        accounts[index] = account
    }
}

extension Session {
    func account(from accountInformation: AccountInformation) -> Account? {
        return accounts.first { account -> Bool in
            account.address == accountInformation.address
        }
    }
    
    func account(from address: String) -> Account? {
        return accounts.first { account -> Bool in
            account.address == address
        }
    }
    
    func accountInformation(from address: String) -> AccountInformation? {
        return applicationConfiguration?.authenticatedUser()?.accounts.first { account -> Bool in
            account.address == address
        }
    }
    
    func index(of account: Account) -> Int? {
        guard let index = accounts.firstIndex(of: account) else {
            return nil
        }
        return index
    }
    
    func addAccount(_ account: Account) {
        guard let index = index(of: account) else {
            accounts.append(account)
            NotificationCenter.default.post(name: .AccountUpdate, object: self, userInfo: ["account": account])
            return
        }
        
        accounts[index].update(with: account)
        NotificationCenter.default.post(name: .AccountUpdate, object: self, userInfo: ["account": accounts[index]])
    }
    
    func updateAccount(_ account: Account) {
        guard let index = index(of: account) else {
            return
        }
        
        accounts[index].update(with: account)
        NotificationCenter.default.post(name: .AccountUpdate, object: self, userInfo: ["account": accounts[index]])
    }
    
    func removeAccount(_ account: Account) {
        guard let index = index(of: account) else {
            return
        }
        
        accounts.remove(at: index)
        NotificationCenter.default.post(name: .AccountUpdate, object: self)
    }
    
    func canSignTransaction(for selectedAccount: inout Account) -> Bool {
        /// Check whether account is a watch account
        if selectedAccount.isWatchAccount() {
           return false
        }

        /// Check whether auth address exists for the selected account.
        if let authAddress = selectedAccount.authAddress {
            if selectedAccount.rekeyDetail?[authAddress] != nil {
                return true
            } else {
                if let authAccount = accounts.first(where: { account -> Bool in
                    authAddress == account.address
                }),
                let ledgerDetail = authAccount.ledgerDetail {
                    selectedAccount.addRekeyDetail(ledgerDetail, for: authAddress)
                    return true
                }
            }

            NotificationBanner.showError(
                "title-error".localized,
                message: "ledger-rekey-error-add-auth".localized(params: authAddress.shortAddressDisplay())
            )
            return false
        }

        /// Check whether ledger details of the selected ledger account exists.
        if selectedAccount.isLedger() {
            if selectedAccount.ledgerDetail == nil {
                NotificationBanner.showError("title-error".localized, message: "ledger-rekey-error-not-found".localized)
                return false
            }
            return true
        }
        
        /// Check whether private key of the selected account exists.
        if privateData(for: selectedAccount.address) == nil {
            NotificationBanner.showError("title-error".localized, message: "ledger-rekey-error-not-found".localized)
            return false
        }
        
        return true
    }

    func createUser(with accounts: [AccountInformation] = []) {
        authenticatedUser = User(accounts: accounts)
    }

    var hasAllAccounts: Bool {
        if let localAccounts = authenticatedUser?.accounts,
           !localAccounts.isEmpty,
           accounts.count == localAccounts.count {
            return true
        }

        return false
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
    func reset(isContactIncluded: Bool) {
        authenticatedUser = nil
        accounts.removeAll()
        applicationConfiguration = nil
        ApplicationConfiguration.clear(entity: ApplicationConfiguration.entityName)
        
        if isContactIncluded {
            Contact.clear(entity: Contact.entityName)
        }
        
        Node.clear(entity: Node.entityName)
        try? privateStorage.removeAll()
        self.clear(.defaults)
        self.clear(.keychain)
        self.isValid = false
        
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.invalidateAccountManagerFetchPolling()
        }
    }
}

extension Session {
    private enum Cache {
        static var configuration: ApplicationConfiguration?
    }
}
