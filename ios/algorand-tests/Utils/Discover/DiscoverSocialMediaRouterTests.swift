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

//   DiscoverSocialMediaRouterTests.swift

import XCTest

@testable import pera_staging

final class DiscoverSocialMediaRouterTests: XCTestCase {

    func testTwitterUsername() throws {
        let router = DiscoverSocialMediaRouter()

        let peraUserExample = URL(string: "https://twitter.com/PeraAlgoWallet")!
        let peraDeeplink = router.route(url: peraUserExample)

        XCTAssertEqual(peraDeeplink, URL(string: "twitter://user?screen_name=PeraAlgoWallet"))

        let invalidURLExample = URL(string: "https://twitter.com/home")!
        let invalidURL2Example = URL(string: "https://twitter.com/explore")!
        let invalidURL3Example = URL(string: "https://twitter.com/settings")!
        let invalidURL4Example = URL(string: "https://twitter.com/notifications")!

        XCTAssertNil(router.route(url: invalidURLExample))
        XCTAssertNil(router.route(url: invalidURL2Example))
        XCTAssertNil(router.route(url: invalidURL3Example))
        XCTAssertNil(router.route(url: invalidURL4Example))

        let hipoUserExample = URL(string: "https://m.twitter.com/hipolabs")!
        let hipoDeeplink = router.route(url: hipoUserExample)

        XCTAssertEqual(hipoDeeplink, URL(string: "twitter://user?screen_name=hipolabs"))

        let tinymanUserExample = URL(string: "twitter://user?screen_name=tinyman")!
        let tinymanDeeplink = router.route(url: tinymanUserExample)
        let invalidURL5Example = URL(string: "twitter://users?screen_name=tinyman")!
        XCTAssertNil(router.route(url: invalidURL5Example))

        XCTAssertEqual(tinymanDeeplink, URL(string: "twitter://user?screen_name=tinyman"))
    }

    func testDiscordInvite() throws {
        let router = DiscoverSocialMediaRouter()

        let peraDiscordExample = URL(string: "https://discord.com/invite/gR2UdkCTXQ")!
        let peraDeeplink = router.route(url: peraDiscordExample)

        XCTAssertEqual(peraDeeplink, URL(string: "com.hammerandchisel.discord://discord.com/invite/gR2UdkCTXQ"))

        let invalidURLExample = URL(string: "https://discord.com/invites/gR2UdkCTXQ")!
        let invalidURL2Example = URL(string: "https://discord.com/gR2UdkCTXQ")!

        XCTAssertNil(router.route(url: invalidURLExample))
        XCTAssertNil(router.route(url: invalidURL2Example))

        let tinymanUserExample = URL(string: "com.hammerandchisel.discord://discord.com/invite/wvHnAdmEv6")!
        let tinymanDeeplink = router.route(url: tinymanUserExample)
        let invalidURL3Example = URL(string: "com.hammerandchisel.discord://discord.com/invite/wvHnAdmEv6/test")!
        XCTAssertNil(router.route(url: invalidURL3Example))

        XCTAssertEqual(tinymanDeeplink, URL(string: "com.hammerandchisel.discord://discord.com/invite/wvHnAdmEv6"))
    }

    func testTelegramInvite() throws {
        let router = DiscoverSocialMediaRouter()

        let peraTelegramExample = URL(string: "https://t.me/PeraWallet")!
        let peraDeeplink = router.route(url: peraTelegramExample)

        XCTAssertEqual(peraDeeplink, URL(string: "tg://resolve?domain=PeraWallet"))

        let invalidURLExample = URL(string: "https://t.me/PeraWallet/Test")!
        XCTAssertNil(router.route(url: invalidURLExample))

        let tinymanUserExample = URL(string: "tg://resolve?domain=tinymanofficial")!
        let tinymanDeeplink = router.route(url: tinymanUserExample)
        let invalidURL2Example = URL(string: "tg://resolve?domain2=tinymanofficialtest")!
        let invalidURL3Example = URL(string: "tg://resolve2?domain=tinymanofficial")!
        XCTAssertNil(router.route(url: invalidURL2Example))
        XCTAssertNil(router.route(url: invalidURL3Example))

        XCTAssertEqual(tinymanDeeplink, URL(string: "tg://resolve?domain=tinymanofficial"))
    }
}
