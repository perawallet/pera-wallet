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

package com.algorand.android.utils

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.Intent.ACTION_VIEW
import android.net.Uri
import androidx.browser.customtabs.CustomTabsIntent

private const val PRIVACY_POLICY_URL = "https://perawallet.app/privacy-policy/"
private const val TERMS_AND_SERVICES_URL = "https://perawallet.app/terms-and-services/"
private const val GOAL_SEEKER_BASE_URL = "https://goalseeker.purestake.io/algorand"
private const val ALGO_EXPLORER_URL = "algoexplorer.io"
private const val MARKET_PAGE_URL = "https://play.google.com/store/apps/details?id=com.algorand.android"
private const val SUPPORT_CENTER_URL = "https://perawallet.app/support/"
private const val TRANSACTION_INFO_URL = "https://perawallet.app/support/transactions/"
private const val GOVERNANCE_URL = "https://governance.algorand.foundation/"
private const val RECOVERY_PASSPHRASE_SUPPORT_URL = "https://perawallet.app/support/passphrase/"
private const val WATCH_ACCOUNT_SUPPORT_URL = "https://perawallet.app/support/watch-accounts/"
const val RECOVER_INFO_URL = "https://perawallet.app/support/recover-account/"
const val LEDGER_HELP_WEB_URL = "https://perawallet.app/support/ledger/"
private const val PERA_INTRODUCTION_URL = "https://perawallet.app/blog/launch-announcement/"
const val PERA_SUPPORT_URL = "https://perawallet.app/support/"

fun Context.openPeraIntroductionBlog() {
    openUrl(PERA_INTRODUCTION_URL)
}

@SuppressWarnings("MaxLineLength")
const val LEDGER_BLUETOOTH_SUPPORT_URL =
    "https://support.ledger.com/hc/en-us/articles/360025864773-Fix-Bluetooth-pairing-issues?support=true)"

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
    try {
        CustomTabsIntent.Builder()
            .build()
            .launchUrl(this, Uri.parse(url))
    } catch (activityNotFoundException: ActivityNotFoundException) {
        recordException(activityNotFoundException)
    }
}

// TODO Refactor here
fun Context.openTransactionInAlgoExplorer(transactionIdWithoutPrefix: String, nodeSlug: String?) {
    val subDomain = if (nodeSlug == MAINNET_NETWORK_SLUG) "" else "$nodeSlug."
    openUrl("https://$subDomain$ALGO_EXPLORER_URL/tx/$transactionIdWithoutPrefix")
}

fun Context.openTransactionInGoalSeeker(transactionIdWithoutPrefix: String, nodeSlug: String?) {
    openUrl("$GOAL_SEEKER_BASE_URL/$nodeSlug/transaction/$transactionIdWithoutPrefix")
}

fun Context.openAssetInAlgoExplorer(assetId: Long?, nodeSlug: String?) {
    val subDomain = if (nodeSlug == MAINNET_NETWORK_SLUG) "" else "$nodeSlug."
    openUrl("https://$subDomain$ALGO_EXPLORER_URL/asset/$assetId")
}

fun Context.openApplicationInAlgoExplorer(applicationId: Long?, nodeSlug: String?) {
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
        recordException(activityNotFoundException)
    }
}

fun Context.openAlgorandGovernancePage() {
    try {
        val intent = Intent(ACTION_VIEW, Uri.parse(GOVERNANCE_URL))
        startActivity(intent)
    } catch (activityNotFoundException: ActivityNotFoundException) {
        recordException(activityNotFoundException)
    }
}

fun Context.openRecoveryPassphraseSupportUrl() {
    openUrl(RECOVERY_PASSPHRASE_SUPPORT_URL)
}

fun Context.openWatchAccountSupportUrl() {
    openUrl(WATCH_ACCOUNT_SUPPORT_URL)
}

fun Context.openPeraSupportUrl() {
    openUrl(PERA_SUPPORT_URL)
}
