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

class LaunchBackBrowserItemIconResIdDecider @Inject constructor() {

    fun provideFallbackBrowserItemIconResId(walletConnectLaunchBackBrowser: WalletConnectLaunchBackBrowser): Int {
        return when (walletConnectLaunchBackBrowser) {
            WalletConnectLaunchBackBrowser.CHROME -> R.drawable.ic_chrome
            WalletConnectLaunchBackBrowser.CHROME_DEV -> R.drawable.ic_chrome_dev
            WalletConnectLaunchBackBrowser.CHROME_BETA -> R.drawable.ic_chrome_beta
            WalletConnectLaunchBackBrowser.CHROME_CANARY -> R.drawable.ic_chrome_canary

            WalletConnectLaunchBackBrowser.GOOGLE_SEARCH -> R.drawable.ic_google_search

            WalletConnectLaunchBackBrowser.OPERA -> R.drawable.ic_opera
            WalletConnectLaunchBackBrowser.OPERA_TOUCH -> R.drawable.ic_opera_touch
            WalletConnectLaunchBackBrowser.OPERA_GX -> R.drawable.ic_opera_gx

            WalletConnectLaunchBackBrowser.YANDEX -> R.drawable.ic_yandex
            WalletConnectLaunchBackBrowser.YANDEX_LITE -> R.drawable.ic_yandex_lite

            WalletConnectLaunchBackBrowser.MICROSOFT_EDGE -> R.drawable.ic_edge

            WalletConnectLaunchBackBrowser.FIREFOX -> R.drawable.ic_firefox
            WalletConnectLaunchBackBrowser.FIREFOX_BETA -> R.drawable.ic_firefox_beta
            WalletConnectLaunchBackBrowser.FIREFOX_FOCUS -> R.drawable.ic_firefox_focus
            WalletConnectLaunchBackBrowser.FIREFOX_NIGHTLY -> R.drawable.ic_firefox_nightly

            WalletConnectLaunchBackBrowser.DUCK_DUCK_GO -> R.drawable.ic_duckduckgo

            WalletConnectLaunchBackBrowser.BRAVE -> R.drawable.ic_brave
            WalletConnectLaunchBackBrowser.BRAVE_BETA -> R.drawable.ic_brave_beta
            WalletConnectLaunchBackBrowser.BRAVE_NIGHTLY -> R.drawable.ic_brave_nightly

            WalletConnectLaunchBackBrowser.BLACKBERRY -> R.drawable.ic_blackberry

            WalletConnectLaunchBackBrowser.VIVALDI -> R.drawable.ic_vivaldi
            WalletConnectLaunchBackBrowser.VIVALDI_SNAPSHOT -> R.drawable.ic_vivaldi_snapshot

            WalletConnectLaunchBackBrowser.WE_CHAT -> R.drawable.ic_wechat

            WalletConnectLaunchBackBrowser.UC_BROWSER -> R.drawable.ic_uc

            WalletConnectLaunchBackBrowser.MAXTHON -> R.drawable.ic_maxthon

            WalletConnectLaunchBackBrowser.PUFFIN -> R.drawable.ic_puffin

            WalletConnectLaunchBackBrowser.SLEIPNIR -> R.drawable.ic_sleipnir

            WalletConnectLaunchBackBrowser.SAMSUNG_INTERNET_FOR_ANDROID -> R.drawable.ic_samsung

            WalletConnectLaunchBackBrowser.NAVER_WHALE_BROWSER -> R.drawable.ic_naver_whale

            WalletConnectLaunchBackBrowser.QQ_BROWSER -> R.drawable.ic_qq_browser

            WalletConnectLaunchBackBrowser.MIUI -> R.drawable.ic_miui
        }
    }
}
