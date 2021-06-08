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

import androidx.core.os.bundleOf
import com.google.firebase.analytics.FirebaseAnalytics

private const val ASSET_DETAIL_ASSET_EVENT_KEY = "asset_detail_asset"
private const val ASSET_DETAIL_ASSET_CHANGE_EVENT_KEY = "asset_detail_asset_change"
private const val ASSET_ID_KEY = "asset_id"

fun FirebaseAnalytics.logAssetDetail(assetId: Long) {
    val bundle = bundleOf(ASSET_ID_KEY to getAssetIdAsEventParam(assetId))
    logEvent(ASSET_DETAIL_ASSET_EVENT_KEY, bundle)
}

fun FirebaseAnalytics.logAssetDetailChange(assetId: Long) {
    val bundle = bundleOf(ASSET_ID_KEY to getAssetIdAsEventParam(assetId))
    logEvent(ASSET_DETAIL_ASSET_CHANGE_EVENT_KEY, bundle)
}
