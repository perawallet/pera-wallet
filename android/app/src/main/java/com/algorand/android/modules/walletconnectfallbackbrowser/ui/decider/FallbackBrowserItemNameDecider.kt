/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.modules.walletconnectfallbackbrowser.ui.decider

import com.algorand.android.R
import com.algorand.android.modules.walletconnectfallbackbrowser.domain.model.WalletConnectFallbackBrowser
import javax.inject.Inject

class FallbackBrowserItemNameDecider @Inject constructor() {

    fun provideFallbackBrowserItemNameResId(walletConnectFallbackBrowser: WalletConnectFallbackBrowser): Int {
        return when (walletConnectFallbackBrowser) {
            WalletConnectFallbackBrowser.CHROME -> R.string.chrome
            WalletConnectFallbackBrowser.CHROME_DEV -> R.string.chrome_dev
            WalletConnectFallbackBrowser.CHROME_BETA -> R.string.chrome_beta
            WalletConnectFallbackBrowser.CHROME_CANARY -> R.string.chrome_canary

            WalletConnectFallbackBrowser.GOOGLE_SEARCH -> R.string.google_search

            WalletConnectFallbackBrowser.OPERA -> R.string.opera
            WalletConnectFallbackBrowser.OPERA_TOUCH -> R.string.opera_touch
            WalletConnectFallbackBrowser.OPERA_GX -> R.string.opera_gx

            WalletConnectFallbackBrowser.YANDEX -> R.string.yandex
            WalletConnectFallbackBrowser.YANDEX_LITE -> R.string.yandex_lite

            WalletConnectFallbackBrowser.MICROSOFT_EDGE -> R.string.microsoft_edge

            WalletConnectFallbackBrowser.FIREFOX -> R.string.firefox
            WalletConnectFallbackBrowser.FIREFOX_BETA -> R.string.firefox_beta
            WalletConnectFallbackBrowser.FIREFOX_FOCUS -> R.string.firefox_focus
            WalletConnectFallbackBrowser.FIREFOX_NIGHTLY -> R.string.firefox_nightly

            WalletConnectFallbackBrowser.DUCK_DUCK_GO -> R.string.duckduckgo

            WalletConnectFallbackBrowser.BRAVE -> R.string.brave
            WalletConnectFallbackBrowser.BRAVE_BETA -> R.string.brave_beta
            WalletConnectFallbackBrowser.BRAVE_NIGHTLY -> R.string.brave_nightly

            WalletConnectFallbackBrowser.BLACKBERRY -> R.string.blackberry

            WalletConnectFallbackBrowser.VIVALDI -> R.string.vivaldi
            WalletConnectFallbackBrowser.VIVALDI_SNAPSHOT -> R.string.vivaldi_snapshot

            WalletConnectFallbackBrowser.WE_CHAT -> R.string.we_chat

            WalletConnectFallbackBrowser.UC_BROWSER -> R.string.uc_browser

            WalletConnectFallbackBrowser.MAXTHON -> R.string.maxthon

            WalletConnectFallbackBrowser.PUFFIN -> R.string.puffin

            WalletConnectFallbackBrowser.SLEIPNIR -> R.string.sleipnir

            WalletConnectFallbackBrowser.SAMSUNG_INTERNET_FOR_ANDROID -> R.string.samsung_internet

            WalletConnectFallbackBrowser.NAVER_WHALE_BROWSER -> R.string.naver_whale_browser

            WalletConnectFallbackBrowser.QQ_BROWSER -> R.string.qq_browser

            WalletConnectFallbackBrowser.MIUI -> R.string.miui
        }
    }
}
