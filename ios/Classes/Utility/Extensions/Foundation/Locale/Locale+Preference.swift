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
//  Locale+Preference.swift

import Foundation

extension Locale {
    static func preferred() -> Locale {
        guard let preferredLanguageIdentifier = Bundle.main.preferredLocalizations.first else {
            return Locale.current
        }
        return Locale(identifier: preferredLanguageIdentifier)
    }

    static func locale(from currencyCode: String) -> Locale? {
        if !commonISOCurrencyCodes.contains(currencyCode) {
            return nil
        }

        if Locale.current.currencyCode == currencyCode {
            return Locale.current
        }

        let localeComponents = [NSLocale.Key.currencyCode.rawValue: currencyCode]
        let localeIdentifier = Locale.identifier(fromComponents: localeComponents)
        return Locale(identifier: localeIdentifier)
    }
}
