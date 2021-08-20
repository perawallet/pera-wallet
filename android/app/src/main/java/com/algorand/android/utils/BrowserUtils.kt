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

package com.algorand.android.utils

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.Intent.ACTION_VIEW
import android.net.Uri
import androidx.browser.customtabs.CustomTabsIntent
import com.google.firebase.crashlytics.FirebaseCrashlytics

private const val PRIVACY_POLICY_URL = "https://www.algorand.com/wallet-privacy-policy"
private const val TERMS_AND_SERVICES_URL = "https://www.algorand.com/wallet-disclaimer"
private const val GOAL_SEEKER_BASE_URL = "https://goalseeker.purestake.io/algorand"
private const val ALGO_EXPLORER_URL = "algoexplorer.io"
private const val MARKET_PAGE_URL = "https://play.google.com/store/apps/details?id=com.algorand.android"
private const val SUPPORT_CENTER_URL = "https://algorandwallet.com/support"
private const val TRANSACTION_INFO_URL = "https://algorandwallet.com/support/transacting"

fun Context.openTermsAndServicesUrl() {
    openUrl(TERMS_AND_SERVICES_URL)
}

fun Context.openPrivacyPolicyUrl() {
    openUrl(PRIVACY_POLICY_URL)
}

fun Context.openSupportCenterUrl() {
    openUrl(SUPPORT_CENTER_URL)
}

fun Context.openTransactionInfoUrl() {
    openUrl(TRANSACTION_INFO_URL)
}

fun Context.openUrl(url: String) {
    CustomTabsIntent.Builder()
        .build()
        .launchUrl(this, Uri.parse(url))
}

// TODO Refactor here
fun Context.openTransactionInAlgoExplorer(transactionIdWithoutPrefix: String, nodeSlug: String?) {
    val subDomain = if (nodeSlug == MAINNET_NETWORK_SLUG) "" else "$nodeSlug."
    openUrl("https://$subDomain$ALGO_EXPLORER_URL/tx/$transactionIdWithoutPrefix")
}

fun Context.openTransactionInGoalSeeker(transactionIdWithoutPrefix: String, nodeSlug: String?) {
    openUrl("$GOAL_SEEKER_BASE_URL/$nodeSlug/transaction/$transactionIdWithoutPrefix")
}

fun Context.openAssetInAlgoExplorer(assetId: String?, nodeSlug: String?) {
    val subDomain = if (nodeSlug == MAINNET_NETWORK_SLUG) "" else "$nodeSlug."
    openUrl("https://$subDomain$ALGO_EXPLORER_URL/asset/$assetId")
}

fun Context.openApplicationInAlgoExplorer(applicationId: String?, nodeSlug: String?) {
    val subDomain = if (nodeSlug == MAINNET_NETWORK_SLUG) "" else "$nodeSlug."
    openUrl("https://$subDomain$ALGO_EXPLORER_URL/application/$applicationId")
}

fun Context.openAssetUrl(assetUrl: String?) {
    openUrl(assetUrl.orEmpty())
}

fun Context.openApplicationPageOnStore() {
    try {
        startActivity(Intent(ACTION_VIEW, Uri.parse(MARKET_PAGE_URL)).apply {
            setPackage("com.android.vending")
        })
    } catch (activityNotFoundException: ActivityNotFoundException) {
        FirebaseCrashlytics.getInstance().recordException(activityNotFoundException)
    }
}
