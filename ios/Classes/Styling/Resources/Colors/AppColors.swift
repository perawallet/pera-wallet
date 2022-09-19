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
//   AppColors.swift

import Foundation
import MacaroonUIKit

/// <note>  This naming is temporary to not coincide with current `Colors` file.
enum AppColors {
    enum Shared {}
    enum Components {}
    enum SendTransaction {}
}

extension AppColors {
    enum Dapp: String, Color {
        case moonpay = "Dapp/moonpay"
    }
}

extension AppColors.Shared {
    enum Global: String, Color {
        case white = "Shared/Global/white"
        case gray400 = "Shared/Global/gray400"
        case gray800 = "Shared/Global/gray800"
        case turquoise600 = "Shared/Global/turquoise600"
    }

    enum System: String, Color {
        case background = "Shared/System/background"
        case chrome = "Shared/System/chrome"
        case theme = "Shared/System/theme"
    }

    enum Layer: String, Color {
        case gray = "Shared/Layer/gray"
        case grayLighter = "Shared/Layer/grayLighter"
        case grayLightest = "Shared/Layer/grayLightest"
    }

    enum Helpers: String, Color {
        case heroBackground = "Shared/Helpers/heroBackground"
        case negative = "Shared/Helpers/negative"
        case negativeLighter = "Shared/Helpers/negativeLighter"
        case positive = "Shared/Helpers/positive"
        case positiveLighter = "Shared/Helpers/positiveLighter"
        case success = "Shared/Helpers/success"
        case testnet = "Shared/Helpers/testnet"
    }

    enum Modality: String, Color {
        case background = "Shared/Modality/background"
    }
}

extension AppColors.Components {
    enum Text: String, Color {
        case main = "Components/Text/main"
        case gray = "Components/Text/gray"
        case grayLighter = "Components/Text/grayLighter"
    }
}

extension AppColors.Components {
    enum Button {
        enum Primary: String, Color {
            case background = "Components/Button/Primary/background"
            case disabledBackground = "Components/Button/Primary/disabledBackground"
            case text = "Components/Button/Primary/text"
            case disabledText = "Components/Button/Primary/disabledText"
            case focus = "Components/Button/Primary/focus"
        }

        enum Secondary: String, Color {
            case background = "Components/Button/Secondary/background"
            case disabledBackground = "Components/Button/Secondary/disabledBackground"
            case text = "Components/Button/Secondary/text"
            case disabledText = "Components/Button/Secondary/disabledText"
        }

        enum Ghost: String, Color {
            case text = "Components/Button/Ghost/text"
        }

        enum TransactionShadow: String, Color {
            case background = "Components/Button/Shadow/background"
            case text = "Components/Button/Shadow/text"
        }
    }

    enum Switch: String, Color {
        case background = "Components/Switch/background"
        case backgroundOff = "Components/Switch/background-off"
    }
}

extension AppColors.Components {
    enum Link: String, Color {
        case primary = "Components/Link/primary"
        case icon = "Components/Link/icon"
    }
}

extension AppColors.Components {
    enum TextField: String, Color {
        case defaultBackground = "Components/TextField/defaultBackground"
        case indicatorActive = "Components/TextField/indicatorActive"
        case indicatorDeactive = "Components/TextField/indicatorDeactive"
        case inputSuggestionBackground = "Components/TextField/inputSuggestionBackground"
        case inputSuggestionSeparator = "Components/TextField/inputSuggestionSeparator"
        case inputSuggestionText = "Components/TextField/inputSuggestionText"
    }
}

extension AppColors.Components {
    enum QR: String, Color {
        case background = "Components/QR/background"
    }
}

extension AppColors.Components {
    enum Banner: String, Color {
        case background = "Components/Banner/background"
        case text = "Components/Banner/text"
        case governanceBackground = "Components/Banner/governance-background"
        case governanceText = "Components/Banner/governance-text"
        case infoBackground = "Components/Banner/info-background"
    }
}

extension AppColors.Components {
    enum ASABanner {
        enum Trusted: String, Color {
            case backround = "Components/ASABanner/Trusted/bg"
            case content = "Components/ASABanner/Trusted/content"
        }

        enum Verified: String, Color {
            case backround = "Components/ASABanner/Verified/bg"
            case content = "Components/ASABanner/Verified/content"
        }

        enum Suspicious: String, Color {
            case backround = "Components/ASABanner/Suspicious/bg"
            case content = "Components/ASABanner/Suspicious/content"
        }
    }
}

extension AppColors.Components {
    enum Toast: String, Color {
        case background = "Components/Toast/bg"
        case description = "Components/Toast/description"
        case title = "Components/Toast/title"
    }
}

extension AppColors.Components {
    enum Shadow: String, Color {
        case dark = "Components/Shadow/dark"
    }
}

extension AppColors.SendTransaction {
    enum Shadow: String, Color {
        case first = "SendTransaction/Shadow/account-first"
        case second = "SendTransaction/Shadow/account-second"
        case third = "SendTransaction/Shadow/account-third"
    }
}
