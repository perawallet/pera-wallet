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

//   TwitterDeeplink.swift

import Foundation

struct TwitterDeeplink: SocialMediaDeeplink {
    let url: URL

    init(url: URL) {
        self.url = url
    }

    func formURL() -> URL? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }

        return formDeeplinkURL(urlComponents: urlComponents) ?? formUniversalLinkURL(urlComponents: urlComponents)
    }

    private func formDeeplinkURL(urlComponents: URLComponents) -> URL? {
        if urlComponents.scheme != "twitter" {
            return nil
        }

        guard urlComponents.host == "user",
              let username = url.queryParameters?["screen_name"] else {
            return nil
        }

        return deeplinkURL(with: username)

    }

    private func formUniversalLinkURL(urlComponents: URLComponents) -> URL? {
        switch urlComponents.host {
        case "twitter.com", "m.twitter.com", "www.twitter.com", "mobile.twitter.com":
            guard url.pathComponents.count == 2, let username = url.pathComponents.last else {
                return nil
            }

            return deeplinkURL(with: username)
        default:
            return nil
        }
    }

    private func deeplinkURL(with username: String) -> URL? {
        switch username {
        case "home", "explore", "messages", "notifications", "settings":
            return nil
        default:
            break
        }

        return URL(string: "twitter://user?screen_name=\(username)")
    }
}
