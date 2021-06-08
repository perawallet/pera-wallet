/*
 * Copyright 2019 Algorand, Inc.
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

private const val TAP_TAB_RECEIVE = "tap_tab_receive"
private const val TAP_ASSET_DETAIL_RECEIVE = "tap_asset_detail_receive"
private const val TAP_SHOW_QR_COPY = "tap_show_qr_copy"
private const val TAP_SHOW_QR_SHARE = "tap_show_qr_share"
private const val TAP_SHOW_QR_SHARE_COMPLETE = "tap_show_qr_share_complete"

fun FirebaseAnalytics.logTapReceive() {
    logEvent(TAP_TAB_RECEIVE, null)
}

fun FirebaseAnalytics.logTapAssetDetailReceive(address: String) {
    logEvent(TAP_ASSET_DETAIL_RECEIVE) {
        param(ADDRESS_KEY, address)
    }
}

fun FirebaseAnalytics.logTapShowQrCopy(address: String) {
    logEvent(TAP_SHOW_QR_COPY) {
        param(ADDRESS_KEY, address)
    }
}

fun FirebaseAnalytics.logTapShowQrShare(address: String) {
    logEvent(TAP_SHOW_QR_SHARE) {
        param(ADDRESS_KEY, address)
    }
}

fun FirebaseAnalytics.logTapShowQrShareComplete(address: String) {
    logEvent(TAP_SHOW_QR_SHARE_COMPLETE) {
        param(ADDRESS_KEY, address)
    }
}
