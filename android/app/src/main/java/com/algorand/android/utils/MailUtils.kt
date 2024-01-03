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
import android.net.Uri
import com.algorand.android.R

const val EMAIL_APPS_URI_SCHEME = "mailto:"
const val PERA_VERIFICATION_MAIL_ADDRESS = "verification@perawallet.app"

fun Context.composeReportAssetEmail(
    assetId: Long,
    assetShortName: String,
    onActivityNotFound: () -> Unit
) {
    val subject = getString(R.string.asa_report_asset_id, assetId)
    val chooserTitle = getString(R.string.report_asset_name, assetShortName)

    val emailIntent = Intent().apply {
        action = Intent.ACTION_SENDTO
        data = Uri.parse(EMAIL_APPS_URI_SCHEME)
        putExtra(Intent.EXTRA_EMAIL, arrayOf(PERA_VERIFICATION_MAIL_ADDRESS))
        putExtra(Intent.EXTRA_SUBJECT, subject)
    }
    try {
        startActivity(Intent.createChooser(emailIntent, chooserTitle))
    } catch (activityNotFoundException: ActivityNotFoundException) {
        onActivityNotFound()
        recordException(activityNotFoundException)
    }
}

fun Context.sendMailRequestUrl(
    url: String,
    onActivityNotFound: () -> Unit
) {
    try {
        startActivity(Intent(Intent.ACTION_SENDTO, Uri.parse(url)))
    } catch (activityNotFoundException: ActivityNotFoundException) {
        onActivityNotFound()
        recordException(activityNotFoundException)
    }
}
