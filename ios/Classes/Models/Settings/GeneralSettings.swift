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
//  GeneralSettings.swift

import UIKit

enum GeneralSettings {
    case account
    case appPreferences
    case support
}

enum AccountSettings: Settings {
    case secureBackup(numberOfAccountsNotBackedUp: Int?)
    case secureBackupLoading
    case security
    case contacts
    case notifications
    case walletConnect
    
    var image: UIImage? {
        switch self {
        case .secureBackup, .secureBackupLoading:
            return img("icon-backup")
        case .security:
            return img("icon-settings-security")
        case .contacts:
            return img("icon-settings-contacts")
        case .notifications:
            return img("icon-settings-notification")
        case .walletConnect:
            return img("icon-settings-wallet-connect")
        }
    }
    
    var name: String {
        switch self {
        case .secureBackup, .secureBackupLoading:
            return "settings-secure-backup-title".localized
        case .security:
            return "settings-security-title".localized
        case .contacts:
            return "contacts-title".localized
        case .notifications:
            return "notifications-title".localized
        case .walletConnect:
            return "settings-wallet-connect-title".localized
        }
    }

    var subtitle: String? {
        switch self {
        case .secureBackup(let numberOfAccountsNotBackedUp):
            guard let numberOfAccountsNotBackedUp else {
                return nil
            }
            
            return "settings-secure-backup-subtitle".localized("\(numberOfAccountsNotBackedUp)")
        default:
            return nil
        }
    }
}

enum AppPreferenceSettings: Settings {
    case language
    case currency
    case appearance
    
    var image: UIImage? {
        switch self {
        case .language:
            return img("icon-settings-language")
        case .currency:
            return img("icon-settings-currency")
        case .appearance:
            return img("icon-settings-theme")
        }
    }
    
    var name: String {
        switch self {
        case .language:
            return "settings-language".localized
        case .currency:
            return "settings-currency".localized
        case .appearance:
            return "settings-theme-set".localized
        }
    }

    var subtitle: String? {
        return nil
    }
}


enum SupportSettings: Settings {
    case feedback
    case appReview
    case termsAndServices
    case privacyPolicy
    case developer
    
    var image: UIImage? {
        switch self {
        case .feedback:
            return img("icon-feedback")
        case .appReview:
            return img("icon-settings-rate")
        case .termsAndServices:
            return img("icon-terms-and-services")
        case .privacyPolicy:
            return img("icon-terms-and-services")
        case .developer:
            return img("icon-settings-developer")
        }
    }
    
    var name: String {
        switch self {
        case .feedback:
            return "settings-support-title".localized
        case .appReview:
            return "settings-rate-title".localized
        case .termsAndServices:
            return "terms-and-services-title".localized
        case .privacyPolicy:
            return "privacy-policy-title".localized
        case .developer:
            return "settings-developer".localized
        }
    }

    var subtitle: String? {
        return nil
    }
}
