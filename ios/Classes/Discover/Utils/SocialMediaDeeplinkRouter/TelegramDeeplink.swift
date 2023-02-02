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

//   TelegramDeeplink.swift

import Foundation

struct TelegramDeeplink: SocialMediaDeeplink {
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
        if urlComponents.scheme != "tg" {
            return nil
        }

        guard urlComponents.host == "resolve",
              let groupName = url.queryParameters?["domain"] else {
            return nil
        }

        return deeplinkURL(groupName: groupName)
    }

    private func formUniversalLinkURL(urlComponents: URLComponents) -> URL? {
        switch urlComponents.host {
        case "t.me", "telegram.me":
            guard url.pathComponents.count == 2, let groupName = url.pathComponents.last else {
                return nil
            }

            return deeplinkURL(groupName: groupName)
        default:
            return nil
        }
    }

    private func deeplinkURL(groupName: String) -> URL? {
        return URL(string: "tg://resolve?domain=\(groupName)")
    }
}
