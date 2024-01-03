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

package com.algorand.android.modules.walletconnect.launchback.base.ui.mapper

import com.algorand.android.modules.walletconnect.launchback.base.domain.model.WalletConnectLaunchBackBrowser
import com.algorand.android.modules.walletconnect.launchback.base.ui.decider.LaunchBackBrowserItemIconResIdDecider
import com.algorand.android.modules.walletconnect.launchback.base.ui.decider.LaunchBackBrowserItemNameDecider
import com.algorand.android.modules.walletconnect.launchback.base.ui.model.LaunchBackBrowserListItem
import javax.inject.Inject

class LaunchBackBrowserListItemMapper @Inject constructor(
    private val launchBackBrowserItemIconResIdDecider: LaunchBackBrowserItemIconResIdDecider,
    private val launchBackBrowserItemNameDecider: LaunchBackBrowserItemNameDecider
) {

    fun mapTo(walletConnectLaunchBackBrowser: WalletConnectLaunchBackBrowser): LaunchBackBrowserListItem {
        return LaunchBackBrowserListItem(
            iconDrawableResId = launchBackBrowserItemIconResIdDecider.provideFallbackBrowserItemIconResId(
                walletConnectLaunchBackBrowser
            ),
            nameStringResId = launchBackBrowserItemNameDecider.provideFallbackBrowserItemNameResId(
                walletConnectLaunchBackBrowser
            ),
            packageName = walletConnectLaunchBackBrowser.packageName
        )
    }
}
