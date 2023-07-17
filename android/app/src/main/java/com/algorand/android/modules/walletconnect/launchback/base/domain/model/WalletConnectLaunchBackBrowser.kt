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

package com.algorand.android.modules.walletconnect.launchback.base.domain.model

import com.algorand.android.BuildConfig
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.BLACKBERRY_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.BRAVE_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.CHROME_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.DUCK_DUCK_GO_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.FIREFOX_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.GOOGLE_SEARCH_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.MAXTHON_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.MICROSOFT_EDGE_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.MIUI_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.NAVER_WHALE_BROWSER_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.OPERA_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.OPERA_GX_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.OPERA_TOUCH_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.PUFFIN_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.QQ_BROWSER_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.SAMSUNG_INTERNET_FOR_ANDROID_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.SLEIPNIR_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.UC_BROWSER_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.VIVALDI_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.WE_CHAT_GROUP
import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowserGroup.YANDEX_GROUP

enum class WalletConnectLaunchBackBrowser(
    val browserGroup: WalletConnectLaunchBackBrowserGroup,
    val packageName: String
) {

    CHROME(CHROME_GROUP, BuildConfig.CHROME_PACKAGE_NAME),
    CHROME_DEV(CHROME_GROUP, BuildConfig.CHROME_DEV_PACKAGE_NAME),
    CHROME_BETA(CHROME_GROUP, BuildConfig.CHROME_BETA_PACKAGE_NAME),
    CHROME_CANARY(CHROME_GROUP, BuildConfig.CHROME_CANARY_PACKAGE_NAME),

    GOOGLE_SEARCH(GOOGLE_SEARCH_GROUP, BuildConfig.GOOGLE_SEARCH_PACKAGE_NAME),

    OPERA(OPERA_GROUP, BuildConfig.OPERA_PACKAGE_NAME),
    OPERA_TOUCH(OPERA_TOUCH_GROUP, BuildConfig.OPERA_TOUCH_PACKAGE_NAME),
    OPERA_GX(OPERA_GX_GROUP, BuildConfig.OPERA_GX_PACKAGE_NAME),

    YANDEX(YANDEX_GROUP, BuildConfig.YANDEX_PACKAGE_NAME),
    YANDEX_LITE(YANDEX_GROUP, BuildConfig.YANDEX_LITE_PACKAGE_NAME),

    MICROSOFT_EDGE(MICROSOFT_EDGE_GROUP, BuildConfig.MICROSOFT_EDGE_PACKAGE_NAME),

    FIREFOX(FIREFOX_GROUP, BuildConfig.FIREFOX_PACKAGE_NAME),
    FIREFOX_NIGHTLY(FIREFOX_GROUP, BuildConfig.FIREFOX_NIGHTLY_PACKAGE_NAME),
    FIREFOX_BETA(FIREFOX_GROUP, BuildConfig.FIREFOX_BETA_PACKAGE_NAME),
    FIREFOX_FOCUS(FIREFOX_GROUP, BuildConfig.FIREFOX_FOCUS_PACKAGE_NAME),

    DUCK_DUCK_GO(DUCK_DUCK_GO_GROUP, BuildConfig.DUCK_DUCK_GO_PACKAGE_NAME),

    BRAVE(BRAVE_GROUP, BuildConfig.BRAVE_PACKAGE_NAME),
    BRAVE_BETA(BRAVE_GROUP, BuildConfig.BRAVE_BETA_PACKAGE_NAME),
    BRAVE_NIGHTLY(BRAVE_GROUP, BuildConfig.BRAVE_NIGHTLY_PACKAGE_NAME),

    BLACKBERRY(BLACKBERRY_GROUP, BuildConfig.BLACKBERRY_PACKAGE_NAME),

    VIVALDI(VIVALDI_GROUP, BuildConfig.VIVALDI_PACKAGE_NAME),
    VIVALDI_SNAPSHOT(VIVALDI_GROUP, BuildConfig.VIVALDI_SNAPSHOT_PACKAGE_NAME),

    WE_CHAT(WE_CHAT_GROUP, BuildConfig.WE_CHAT_PACKAGE_NAME),

    UC_BROWSER(UC_BROWSER_GROUP, BuildConfig.UC_BROWSER_PACKAGE_NAME),

    MAXTHON(MAXTHON_GROUP, BuildConfig.MAXTHON_PACKAGE_NAME),

    PUFFIN(PUFFIN_GROUP, BuildConfig.PUFFIN_PACKAGE_NAME),

    SLEIPNIR(SLEIPNIR_GROUP, BuildConfig.SLEIPNIR_PACKAGE_NAME),

    SAMSUNG_INTERNET_FOR_ANDROID(
        SAMSUNG_INTERNET_FOR_ANDROID_GROUP,
        BuildConfig.SAMSUNG_INTERNET_FOR_ANDROID_PACKAGE_NAME
    ),

    NAVER_WHALE_BROWSER(NAVER_WHALE_BROWSER_GROUP, BuildConfig.NAVER_WHALE_BROWSER_PACKAGE_NAME),

    QQ_BROWSER(QQ_BROWSER_GROUP, BuildConfig.QQ_BROWSER_PACKAGE_NAME),

    MIUI(MIUI_GROUP, BuildConfig.MIUI_PACKAGE_NAME);

    companion object {
        fun getBrowserListByGroup(browserGroup: WalletConnectLaunchBackBrowserGroup) =
            values().filter { it.browserGroup == browserGroup }
    }
}
