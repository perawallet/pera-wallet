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

class FallbackBrowserItemIconResIdDecider @Inject constructor() {

    fun provideFallbackBrowserItemIconResId(walletConnectFallbackBrowser: WalletConnectFallbackBrowser): Int {
        return when (walletConnectFallbackBrowser) {
            WalletConnectFallbackBrowser.CHROME -> R.drawable.ic_chrome
            WalletConnectFallbackBrowser.CHROME_DEV -> R.drawable.ic_chrome_dev
            WalletConnectFallbackBrowser.CHROME_BETA -> R.drawable.ic_chrome_beta
            WalletConnectFallbackBrowser.CHROME_CANARY -> R.drawable.ic_chrome_canary

            WalletConnectFallbackBrowser.GOOGLE_SEARCH -> R.drawable.ic_google_search

            WalletConnectFallbackBrowser.OPERA -> R.drawable.ic_opera
            WalletConnectFallbackBrowser.OPERA_TOUCH -> R.drawable.ic_opera_touch
            WalletConnectFallbackBrowser.OPERA_GX -> R.drawable.ic_opera_gx

            WalletConnectFallbackBrowser.YANDEX -> R.drawable.ic_yandex
            WalletConnectFallbackBrowser.YANDEX_LITE -> R.drawable.ic_yandex_lite

            WalletConnectFallbackBrowser.MICROSOFT_EDGE -> R.drawable.ic_edge

            WalletConnectFallbackBrowser.FIREFOX -> R.drawable.ic_firefox
            WalletConnectFallbackBrowser.FIREFOX_BETA -> R.drawable.ic_firefox_beta
            WalletConnectFallbackBrowser.FIREFOX_FOCUS -> R.drawable.ic_firefox_focus
            WalletConnectFallbackBrowser.FIREFOX_NIGHTLY -> R.drawable.ic_firefox_nightly

            WalletConnectFallbackBrowser.DUCK_DUCK_GO -> R.drawable.ic_duckduckgo

            WalletConnectFallbackBrowser.BRAVE -> R.drawable.ic_brave
            WalletConnectFallbackBrowser.BRAVE_BETA -> R.drawable.ic_brave_beta
            WalletConnectFallbackBrowser.BRAVE_NIGHTLY -> R.drawable.ic_brave_nightly

            WalletConnectFallbackBrowser.BLACKBERRY -> R.drawable.ic_blackberry

            WalletConnectFallbackBrowser.VIVALDI -> R.drawable.ic_vivaldi
            WalletConnectFallbackBrowser.VIVALDI_SNAPSHOT -> R.drawable.ic_vivaldi_snapshot

            WalletConnectFallbackBrowser.WE_CHAT -> R.drawable.ic_wechat

            WalletConnectFallbackBrowser.UC_BROWSER -> R.drawable.ic_uc

            WalletConnectFallbackBrowser.MAXTHON -> R.drawable.ic_maxthon

            WalletConnectFallbackBrowser.PUFFIN -> R.drawable.ic_puffin

            WalletConnectFallbackBrowser.SLEIPNIR -> R.drawable.ic_sleipnir

            WalletConnectFallbackBrowser.SAMSUNG_INTERNET_FOR_ANDROID -> R.drawable.ic_samsung

            WalletConnectFallbackBrowser.NAVER_WHALE_BROWSER -> R.drawable.ic_naver_whale

            WalletConnectFallbackBrowser.QQ_BROWSER -> R.drawable.ic_qq_browser

            WalletConnectFallbackBrowser.MIUI -> R.drawable.ic_miui
        }
    }
}
