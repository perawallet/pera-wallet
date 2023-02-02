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

//   DiscordDeeplink.swift

import Foundation

struct DiscordDeeplink: SocialMediaDeeplink {
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
        guard urlComponents.scheme == "com.hammerandchisel.discord" else {
            return nil
        }

        return deeplinkURL()
    }

    private func formUniversalLinkURL(urlComponents: URLComponents) -> URL? {
        switch urlComponents.host {
        case "discord.com":
            return deeplinkURL()
        default:
            return nil
        }
    }

    private func deeplinkURL() -> URL? {
        guard url.pathComponents.count == 3 else {
            return nil
        }

        var pathComponents = url.pathComponents
        pathComponents.removeAll { path in
            path == "/"
        }

        guard pathComponents.first == "invite" else {
            return nil
        }

        let inviteID = pathComponents.last

        guard let inviteID else {
            return nil
        }

        return URL(string: "com.hammerandchisel.discord://discord.com/invite/\(inviteID)")
    }
}
