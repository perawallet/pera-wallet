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

//   DiscoverSocialMediaLinkParser.swift

import Foundation

final class DiscoverSocialMediaRouter {
    /// <note>: route function description
    /// route function gets the URL from InAppBrowser and checks the URL
    /// If URL is valid for specific social media apps, it will return the necessary deeplink URLs to parse
    /// example: https://twitter.com/PeraAlgoWallet it will be converted to => twitter://user?screen_name=PeraAlgoWallet
    func route(url: URL) -> URL? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }

        let deeplink: SocialMediaDeeplink

        switch urlComponents.scheme {
        case "twitter":
            deeplink = TwitterDeeplink(url: url)
        case "com.hammerandchisel.discord":
            deeplink = DiscordDeeplink(url: url)
        case "tg":
            deeplink = TelegramDeeplink(url: url)
        case "https", "http":
            switch urlComponents.host {
            case "twitter.com", "m.twitter.com", "www.twitter.com", "mobile.twitter.com":
                deeplink = TwitterDeeplink(url: url)
            case "discord.com":
                deeplink = DiscordDeeplink(url: url)
            case "t.me", "telegram.me":
                deeplink = TelegramDeeplink(url: url)
            default:
                return nil
            }
        default:
            return nil
        }

        return deeplink.formURL()
    }
}
