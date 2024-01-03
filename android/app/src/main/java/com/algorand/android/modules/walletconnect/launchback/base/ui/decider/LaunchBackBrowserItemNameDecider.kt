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

package com.algorand.android.modules.walletconnect.launchback.base.ui.decider

import com.algorand.android.R
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowser
import javax.inject.Inject

class LaunchBackBrowserItemNameDecider @Inject constructor() {

    fun provideFallbackBrowserItemNameResId(walletConnectLaunchBackBrowser: WalletConnectLaunchBackBrowser): Int {
        return when (walletConnectLaunchBackBrowser) {
            WalletConnectLaunchBackBrowser.CHROME -> R.string.chrome
            WalletConnectLaunchBackBrowser.CHROME_DEV -> R.string.chrome_dev
            WalletConnectLaunchBackBrowser.CHROME_BETA -> R.string.chrome_beta
            WalletConnectLaunchBackBrowser.CHROME_CANARY -> R.string.chrome_canary

            WalletConnectLaunchBackBrowser.GOOGLE_SEARCH -> R.string.google_search

            WalletConnectLaunchBackBrowser.OPERA -> R.string.opera
            WalletConnectLaunchBackBrowser.OPERA_TOUCH -> R.string.opera_touch
            WalletConnectLaunchBackBrowser.OPERA_GX -> R.string.opera_gx

            WalletConnectLaunchBackBrowser.YANDEX -> R.string.yandex
            WalletConnectLaunchBackBrowser.YANDEX_LITE -> R.string.yandex_lite

            WalletConnectLaunchBackBrowser.MICROSOFT_EDGE -> R.string.microsoft_edge

            WalletConnectLaunchBackBrowser.FIREFOX -> R.string.firefox
            WalletConnectLaunchBackBrowser.FIREFOX_BETA -> R.string.firefox_beta
            WalletConnectLaunchBackBrowser.FIREFOX_FOCUS -> R.string.firefox_focus
            WalletConnectLaunchBackBrowser.FIREFOX_NIGHTLY -> R.string.firefox_nightly

            WalletConnectLaunchBackBrowser.DUCK_DUCK_GO -> R.string.duckduckgo

            WalletConnectLaunchBackBrowser.BRAVE -> R.string.brave
            WalletConnectLaunchBackBrowser.BRAVE_BETA -> R.string.brave_beta
            WalletConnectLaunchBackBrowser.BRAVE_NIGHTLY -> R.string.brave_nightly

            WalletConnectLaunchBackBrowser.BLACKBERRY -> R.string.blackberry

            WalletConnectLaunchBackBrowser.VIVALDI -> R.string.vivaldi
            WalletConnectLaunchBackBrowser.VIVALDI_SNAPSHOT -> R.string.vivaldi_snapshot

            WalletConnectLaunchBackBrowser.WE_CHAT -> R.string.we_chat

            WalletConnectLaunchBackBrowser.UC_BROWSER -> R.string.uc_browser

            WalletConnectLaunchBackBrowser.MAXTHON -> R.string.maxthon

            WalletConnectLaunchBackBrowser.PUFFIN -> R.string.puffin

            WalletConnectLaunchBackBrowser.SLEIPNIR -> R.string.sleipnir

            WalletConnectLaunchBackBrowser.SAMSUNG_INTERNET_FOR_ANDROID -> R.string.samsung_internet

            WalletConnectLaunchBackBrowser.NAVER_WHALE_BROWSER -> R.string.naver_whale_browser

            WalletConnectLaunchBackBrowser.QQ_BROWSER -> R.string.qq_browser

            WalletConnectLaunchBackBrowser.MIUI -> R.string.miui
        }
    }
}
