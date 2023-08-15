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
//  String+Localization.swift

import Foundation

extension String {
    var localized: String {
        let value = localizedString()
        
        if shouldReturnLocalizedValue(value) {
            return value
        }
        
        return getEnglishFallbackValue()
    }
    
    func localized(params: CVarArg...) -> String {
        let value = localizedString()
        
        if shouldReturnLocalizedValue(value) {
            return formattedString(
                value,
                params: params
            )
        }
        
        let fallbackValue = getEnglishFallbackValue()
        return formattedString(
            fallbackValue,
            params: params
        )
    }
}

extension String {
    private func localizedString() -> String {
        return NSLocalizedString(
            self,
            comment: ""
        )
    }
    
    private func shouldReturnLocalizedValue(_ value: String) -> Bool {
        return value != self || NSLocale.preferredLanguages.first == "en"
    }
    
    private func getEnglishFallbackValue() -> String {
        guard let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return self
        }
        
        return NSLocalizedString(
            self,
            bundle: bundle,
            comment: ""
        )
    }
    
    func formattedString(
        _ value: String,
        params: CVarArg...
    ) -> String {
        return String(
            format: value,
            arguments: params
        )
    }
}
