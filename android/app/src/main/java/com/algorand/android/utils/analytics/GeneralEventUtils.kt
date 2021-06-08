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
import com.algorand.android.models.AssetInformation
import com.google.firebase.analytics.FirebaseAnalytics

private const val REKEY_EVENT_KEY = "rekey"

fun FirebaseAnalytics.logRekeyEvent() {
    logEvent(REKEY_EVENT_KEY, null)
}

private const val CURRENCY_CHANGE_EVENT_KEY = "currency_change"
private const val CURRENCY_ID_KEY = "currency_id"

private const val LANGUAGE_CHANGE_EVENT_KEY = "language_change"
private const val LANGUAGE_ID_KEY = "language_id"

private const val ALGO_ASSET_ID = "algos"

fun FirebaseAnalytics.logCurrencyChange(newCurrencyId: String) {
    val bundle = bundleOf(CURRENCY_ID_KEY to newCurrencyId)
    logEvent(CURRENCY_CHANGE_EVENT_KEY, bundle)
}

fun FirebaseAnalytics.logLanguageChange(newLanguageId: String) {
    val bundle = bundleOf(LANGUAGE_ID_KEY to newLanguageId)
    logEvent(LANGUAGE_CHANGE_EVENT_KEY, bundle)
}

fun FirebaseAnalytics.logScreen(page: String) {
    logEvent(page, null)
}

fun getAssetIdAsEventParam(assetId: Long): String {
    return if (assetId == AssetInformation.ALGORAND_ID) ALGO_ASSET_ID else assetId.toString()
}
