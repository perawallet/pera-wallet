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

//   URL+Extensions.swift

import Foundation
import MacaroonUtils

extension URL {
    var presentationString: String? {
        let host = host.unwrapNonEmptyString() ?? absoluteString
        return host.without(prefix: "www.")
    }
    var isMailURL: Bool {
        return scheme?.lowercased() == "mailto"
    }
    var isWebURL: Bool {
        return (scheme?.lowercased() == "http" || scheme?.lowercased() == "https") && host != nil
    }
}

extension URL {
    func straightened() -> URL? {
        var components = URLComponents(string: absoluteString)

        /// <warning>
        /// Only HTTP and HTTPS schemes are supported. Otherwise, it crashes.
        switch components?.scheme {
        case .none:
            components?.scheme = "https"
            return components?.url
        case "http", "https":
            return components?.url
        default:
            return nil
        }
    }
}
