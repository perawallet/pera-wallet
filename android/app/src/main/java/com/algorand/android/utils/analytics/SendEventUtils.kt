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

package com.algorand.android.utils.analytics

import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.analytics.ktx.logEvent

private const val ADDRESS_KEY = "address"

private const val TAP_TAB_SEND = "tap_tab_receive"
private const val TAP_ASSET_DETAIL_SEND = "tap_asset_detail_receive"

fun FirebaseAnalytics.logTapSend() {
    logEvent(TAP_TAB_SEND, null)
}

fun FirebaseAnalytics.logTapAssetDetailSend(address: String) {
    logEvent(TAP_ASSET_DETAIL_SEND) {
        param(ADDRESS_KEY, address)
    }
}
