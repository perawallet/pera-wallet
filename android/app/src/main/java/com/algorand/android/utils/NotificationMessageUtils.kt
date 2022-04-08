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

import android.content.Context
import androidx.core.content.ContextCompat
import androidx.core.content.res.ResourcesCompat
import androidx.core.text.buildSpannedString
import androidx.core.text.color
import androidx.core.text.inSpans
import com.algorand.android.R
import com.algorand.android.models.AssetNotificationDescription
import java.util.Locale

// TODO replace it with annotation
private fun Context.getAssetNameCharSequence(
    context: Context,
    asset: AssetNotificationDescription?
): CharSequence {
    return buildSpannedString {
        val isFullNameNullOrBlank = asset?.fullName.isNullOrBlank()
        val isShortNameNullOrBlank = asset?.shortName.isNullOrBlank()
        if (!isFullNameNullOrBlank) {
            inSpans(CustomTypefaceSpan(ResourcesCompat.getFont(context, R.font.dmsans_medium))) {
                append(asset?.fullName)
            }
        }
        if (!isShortNameNullOrBlank) {
            if (!isFullNameNullOrBlank) {
                addSpace()
            }
            color(ContextCompat.getColor(context, R.color.gray_500)) {
                append(getString(R.string.ticker_asset_format, asset?.shortName?.toUpperCase(Locale.ENGLISH)))
            }
        }
        if (isFullNameNullOrBlank && isShortNameNullOrBlank) {
            addUnnamedAssetName(context)
        }
    }
}

fun Context.setupAlgoSentMessage(
    formattedAmount: String?,
    senderName: String?,
    receiverName: String?,
    asset: AssetNotificationDescription?
): CharSequence {
    return getXmlStyledString(
        stringResId = R.string.transaction_send_successful,
        replacementList = listOf(
            "amount" to formattedAmount.orEmpty(),
            "receiver" to receiverName.orEmpty(),
            "sender" to senderName.orEmpty(),
            "asset" to getAssetNameCharSequence(this, asset)
        )
    )
}

fun Context.setupFailedMessage(
    formattedAmount: String?,
    senderName: String?,
    receiverName: String?,
    asset: AssetNotificationDescription?
): CharSequence {
    return getXmlStyledString(
        stringResId = R.string.transaction_send_failed,
        replacementList = listOf(
            "amount" to formattedAmount.orEmpty(),
            "receiver" to receiverName.orEmpty(),
            "sender" to senderName.orEmpty(),
            "asset" to getAssetNameCharSequence(this, asset)
        )
    )
}

fun Context.setupAlgoReceivedMessage(
    formattedAmount: String?,
    senderName: String?,
    receiverName: String?,
    asset: AssetNotificationDescription?
): CharSequence {
    return getXmlStyledString(
        stringResId = R.string.notification_algo_received_message,
        replacementList = listOf(
            "amount" to formattedAmount.orEmpty(),
            "receiver" to receiverName.orEmpty(),
            "sender" to senderName.orEmpty(),
            "asset" to getAssetNameCharSequence(this, asset)
        )
    )
}

fun Context.setupAssetSupportSuccessMessage(
    senderName: String?,
    asset: AssetNotificationDescription?
): CharSequence {
    return getXmlStyledString(
        stringResId = R.string.asset_support_success,
        replacementList = listOf(
            "sender" to senderName.orEmpty(),
            "asset" to getAssetNameCharSequence(this, asset)
        )
    )
}

fun Context.setupAssetSupportRequestMessage(
    senderName: String?,
    asset: AssetNotificationDescription?
): CharSequence {
    return getXmlStyledString(
        stringResId = R.string.asset_support_request,
        replacementList = listOf(
            "sender" to senderName.orEmpty(),
            "asset" to getAssetNameCharSequence(this, asset)
        )
    )
}
