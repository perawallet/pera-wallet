/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.modules.walletconnectfallbackbrowser.domain.model

// Deeplink response list is retrieved from https://gist.github.com/mucahit/2055be182e4304e120ebd6ac2b8ac1e6
enum class WalletConnectFallbackBrowserGroup(val value: String) {
    CHROME_GROUP("Chrome"),
    GOOGLE_SEARCH_GROUP("Google Search"),
    OPERA_GROUP("Opera"),
    OPERA_TOUCH_GROUP("Opera Touch"),
    OPERA_GX_GROUP("Opera GX"),
    YANDEX_GROUP("Yandex Browser"),
    MICROSOFT_EDGE_GROUP("Microsoft Edge"),
    FIREFOX_GROUP("Firefox"),
    DUCK_DUCK_GO_GROUP("DuckDuckGo"),
    BRAVE_GROUP("Brave"),
    BLACKBERRY_GROUP("BlackBerry"),
    VIVALDI_GROUP("Vivaldi"),
    WE_CHAT_GROUP("WeChat"),
    UC_BROWSER_GROUP("UC Browser"),
    MAXTHON_GROUP("Maxthon"),
    PUFFIN_GROUP("Puffin"),
    SLEIPNIR_GROUP("Sleipnir"),
    SAMSUNG_INTERNET_FOR_ANDROID_GROUP("Samsung Internet for Android"),
    NAVER_WHALE_BROWSER_GROUP("NAVER Whale Browser"),
    QQ_BROWSER_GROUP("QQ Browser"),
    MIUI_GROUP("Miui"),
    OTHER_GROUP("");

    companion object {
        fun getByDeeplinkResponse(deeplinkResponse: String): WalletConnectFallbackBrowserGroup =
            values().firstOrNull { it.value == deeplinkResponse } ?: OTHER_GROUP
    }
}
