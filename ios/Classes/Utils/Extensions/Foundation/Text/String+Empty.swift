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
//  String+Empty.swift

import Foundation

extension String {
    static let empty = ""

    func isUnknown() -> Bool {
        return self == "title-unknown".localized
    }
    
    var isEmptyOrBlank: Bool {
        if isEmpty {
            return true
        }
        return allSatisfy { $0.isWhitespace }
    }
    
    func addByteLimiter(maximumLimitInByte: Int) -> String {
        guard let utf8DecodedData = data(using: .utf8),
            let utf8DecodedString = String(data: utf8DecodedData, encoding: .utf8) else {
                return self
        }
        
        var byteLimitedString = utf8DecodedString
        while byteLimitedString.count > 1024 {
            byteLimitedString.removeLast(1)
        }
        
        return byteLimitedString
    }
}
