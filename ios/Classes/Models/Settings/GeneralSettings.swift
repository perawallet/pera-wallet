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
//  GeneralSettings.swift

import UIKit

enum GeneralSettings: Settings {
    case developer
    case password
    case localAuthentication
    case notifications
    case rewards
    case language
    case currency
    case support
    case appReview
    case termsAndServices
    case privacyPolicy
    case appearance
    
    var image: UIImage? {
        switch self {
        case .developer:
            return img("icon-settings-developer")
        case .password:
            return img("icon-settings-password")
        case .localAuthentication:
            return img("icon-settings-faceid")
        case .notifications:
            return img("icon-settings-notification")
        case .rewards:
            return img("icon-settings-reward")
        case .language:
            return img("icon-settings-language")
        case .currency:
            return img("icon-settings-currency")
        case .appearance:
            return img("icon-settings-theme")
        case .support:
            return img("icon-feedback")
        case .appReview:
            return img("icon-settings-rate")
        case .termsAndServices:
            return img("icon-terms-and-services")
        case .privacyPolicy:
            return img("icon-terms-and-services")
        }
    }
    
    var name: String {
        switch self {
        case .developer:
            return "settings-developer".localized
        case .password:
            return "settings-change-password".localized
        case .localAuthentication:
            return "settings-local-authentication".localized
        case .notifications:
            return "notifications-title".localized
        case .rewards:
            return "rewards-show-title".localized
        case .language:
            return "settings-language".localized
        case .currency:
            return "settings-currency".localized
        case .appearance:
            return "settings-theme-set".localized
        case .support:
            return "settings-support-title".localized
        case .appReview:
            return "settings-rate-title".localized
        case .termsAndServices:
            return "terms-and-services-title".localized
        case .privacyPolicy:
            return "privacy-policy-title".localized
        }
    }
}
