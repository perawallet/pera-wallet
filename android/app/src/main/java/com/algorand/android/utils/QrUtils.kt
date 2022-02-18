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
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.ui.qr.QrCodeScannerFragment
import com.algorand.android.utils.walletconnect.WALLET_CONNECT_URL_PREFIX
import com.google.gson.Gson
import com.google.zxing.BarcodeFormat
import com.journeyapps.barcodescanner.BarcodeEncoder
import java.math.BigInteger

private const val MNEMONIC_KEY = "mnemonic"
private const val AMOUNT_KEY = "amount"
private const val LABEL_KEY = "label"
private const val ASSET_ID_KEY = "asset"
private const val NOTE_KEY = "note"
private const val XNOTE_KEY = "xnote"
private const val DEEPLINK_PREFIX = "algorand://"
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

fun getDeeplinkUrl(address: String, amount: BigInteger? = null, assetId: Long? = null): String {
    return StringBuilder().apply {
        append("$DEEPLINK_PREFIX$address")
        getDeeplinkQueryList(amount, assetId).forEachIndexed { index, (key, value) ->
            append(if (index == 0) QUERY_START_CHAR else QUERY_NEXT_CHAR)
            append("$key=$value")
        }
    }.toString()
}

private fun getDeeplinkQueryList(amount: BigInteger?, assetId: Long?): List<Pair<String, String>> {
    val deeplinkQueryList = mutableListOf<Pair<String, String>>()
    if (amount != null) {
        deeplinkQueryList.add(Pair(AMOUNT_KEY, amount.toString()))
    }
    if (assetId != null && assetId > 0) {
        deeplinkQueryList.add(Pair(ASSET_ID_KEY, assetId.toString()))
    }
    return deeplinkQueryList
}

fun getMnemonicQrContent(mnemonic: String): String {
    return "{\"version\":\"1.0\", \"$MNEMONIC_KEY\":\"$mnemonic\"}"
}

private fun decodeMnemonicFromQr(qrContent: String): DecodedQrCode? {
    return try {
        Gson().fromJson(qrContent, DecodedQrCode::class.java)
    } catch (exception: Exception) {
        null
    }
}

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

    if (qrContent.startsWith(DEEPLINK_PREFIX)) {
        val addressQuerySplit = qrContent.removePrefix(DEEPLINK_PREFIX).split(QUERY_START_CHAR)
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
    return if (address.isValidAddress()) {
        DecodedQrCode(
            address = address,
            label = label,
            amount = amount,
            note = note,
            xnote = xnote,
            assetId = assetId
        )
    } else {
        null
    }
}

private fun decodeWalletConnectQr(qrCode: String): DecodedQrCode {
    return DecodedQrCode(walletConnectUrl = qrCode)
}

fun decodeAccountPublicKeyFromQr(qrContent: String?): DecodedQrCode? {
    // Removing prefix for Algo Explorer support because they return public key with a deeplink prefix.
    val address = qrContent?.removePrefix(DEEPLINK_PREFIX)
    if (address.isValidAddress().not()) {
        return null
    }
    return DecodedQrCode(address = address)
}

fun getContentOfQR(
    deeplink: String,
    scanReturnTypeList: Array<QrCodeScannerFragment.ScanReturnType>
): Pair<QrCodeScannerFragment.ScanReturnType?, DecodedQrCode?> {
    var decodedQrCode: DecodedQrCode? = null
    var scanResult: QrCodeScannerFragment.ScanReturnType? = null

    scanReturnTypeList.forEach { scanType ->
        scanResult = scanType
        decodedQrCode = when (scanType) {
            QrCodeScannerFragment.ScanReturnType.MNEMONIC_NAVIGATE_BACK -> decodeMnemonicFromQr(deeplink)
            QrCodeScannerFragment.ScanReturnType.WALLET_CONNECT -> decodeWalletConnectQr(deeplink)
            QrCodeScannerFragment.ScanReturnType.ADDRESS_NAVIGATE_BACK -> decodeAccountPublicKeyFromQr(deeplink)
            else -> decodeDeeplink(deeplink)
        }
        // TODO: 13.08.2021 decodeDeepLink also handle Wallet Connect QR Code, so we should ignore this case for now.
        if (scanResult != QrCodeScannerFragment.ScanReturnType.WALLET_CONNECT &&
            decodedQrCode?.walletConnectUrl != null
        ) {
            return@forEach
        }
        if (decodedQrCode != null) return Pair(scanResult, decodedQrCode)
    }

    return Pair(scanResult, decodedQrCode)
}
