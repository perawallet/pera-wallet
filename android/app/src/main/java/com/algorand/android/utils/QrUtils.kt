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

import android.graphics.Bitmap
import android.net.Uri
import com.algorand.android.BuildConfig
import com.algorand.android.R
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.utils.walletconnect.WALLET_CONNECT_URL_PREFIX
import com.google.zxing.BarcodeFormat
import com.journeyapps.barcodescanner.BarcodeEncoder
import java.math.BigInteger

private const val MNEMONIC_KEY = "mnemonic"
private const val AMOUNT_KEY = "amount"
private const val LABEL_KEY = "label"
private const val ASSET_ID_KEY = "asset"
private const val NOTE_KEY = "note"
private const val XNOTE_KEY = "xnote"
private const val TRANSACTION_ID_KEY = "transactionId"
private const val QUERY_START_CHAR = "?"
private const val QUERY_NEXT_CHAR = "&"
private const val QUERY_KEY_ASSIGNER_CHAR = "="
private const val ADDRESS_INDEX = 0
private const val QUERY_INDEX = 1

fun getQrCodeBitmap(size: Int, qrContent: String): Bitmap? {
    return try {
        // The QR code has self padding about 28dp.
        BarcodeEncoder().encodeBitmap(qrContent, BarcodeFormat.QR_CODE, size, size)
    } catch (e: Exception) {
        null
    }
}

fun getDeepLinkUrl(address: String, amount: BigInteger? = null, assetId: Long? = null): String {
    return Uri.parse(BuildConfig.DEEPLINK_PREFIX).buildUpon()
        .authority(address)
        .apply {
            if (amount != null) appendQueryParameter(AMOUNT_KEY, amount.toString())
            if (assetId != null) appendQueryParameter(ASSET_ID_KEY, assetId.toString())
        }
        .toString()
}

@SuppressWarnings("ReturnCount", "LongMethod")
fun decodeDeeplink(qrContent: String?): DecodedQrCode? {
    if (qrContent.isNullOrBlank()) {
        return null
    }
    var label: String? = null
    var amount: BigInteger? = null
    var assetId: Long? = null
    var note: String? = null
    var xnote: String? = null
    val address: String

    if (qrContent.startsWith(BuildConfig.DEEPLINK_PREFIX)) {
        val addressQuerySplit = qrContent.removePrefix(BuildConfig.DEEPLINK_PREFIX).split(QUERY_START_CHAR)
        address = addressQuerySplit.getOrNull(ADDRESS_INDEX) ?: return null
        addressQuerySplit.getOrNull(QUERY_INDEX)
            ?.split(QUERY_NEXT_CHAR)
            ?.map { keyValueQueryString ->
                val keyValueList = keyValueQueryString.split(QUERY_KEY_ASSIGNER_CHAR)
                Pair(keyValueList.getOrNull(0), keyValueList.getOrNull(1))
            }
            ?.forEach { (queryKey, queryValue) ->
                when (queryKey) {
                    LABEL_KEY -> label = queryValue?.decodeUrl()
                    AMOUNT_KEY -> amount = queryValue?.decodeUrl()?.toBigIntegerOrNull()
                    ASSET_ID_KEY -> assetId = queryValue?.decodeUrl()?.toLongOrNull()
                    NOTE_KEY -> note = queryValue?.decodeUrl()
                    XNOTE_KEY -> xnote = queryValue?.decodeUrl()
                }
            }
    } else if (qrContent.startsWith(WALLET_CONNECT_URL_PREFIX)) {
        return decodeWalletConnectQr(qrContent)
    } else {
        address = qrContent
    }
    if (address.isValidAddress()) {
        amount?.let {
            return DecodedQrCode.Success.Deeplink.AssetTransaction(
                address = address,
                label = label,
                amount = it,
                note = note,
                xnote = xnote,
                assetId = assetId,
            )
        }
        return DecodedQrCode.Success.Deeplink.AddContact(
            contactPublicKey = address,
            contactName = label
        )
    } else {
        return null
    }
}

private fun decodeWalletConnectQr(qrCode: String): DecodedQrCode {
    return if (qrCode.startsWith(WALLET_CONNECT_URL_PREFIX)) {
        DecodedQrCode.Success.Deeplink.WalletConnect(walletConnectUrl = qrCode)
    } else {
        DecodedQrCode.Error.WalletConnect(R.string.could_not_create_wallet_connect)
    }
}
