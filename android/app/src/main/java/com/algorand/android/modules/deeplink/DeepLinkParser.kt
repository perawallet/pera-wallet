@file:Suppress("MaxLineLength", "TooManyFunctions")

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

package com.algorand.android.modules.deeplink

import android.net.Uri
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.RawMnemonicPayload
import com.algorand.android.models.WebQrCode
import com.algorand.android.modules.deeplink.domain.model.NotificationGroupType
import com.algorand.android.modules.deeplink.domain.model.RawDeepLink
import com.algorand.android.modules.webimport.common.data.mapper.WebImportQrCodeMapper
import com.algorand.android.modules.webimport.common.data.model.WebImportQrCode
import com.algorand.android.utils.fromJson
import com.algorand.android.utils.isValidAddress
import com.squareup.moshi.Moshi
import java.math.BigInteger
import javax.inject.Inject

class DeepLinkParser @Inject constructor(
    private val moshi: Moshi,
    private val webImportQrCodeMapper: WebImportQrCodeMapper
) {

    fun parseDeepLink(deepLink: String): RawDeepLink {
        val parsedUri = Uri.parse(deepLink)
        return RawDeepLink(
            accountAddress = getAccountAddress(parsedUri),
            walletConnectUrl = getWalletConnectUrl(parsedUri),
            assetId = getAssetId(parsedUri),
            amount = getAmount(parsedUri),
            note = getNote(parsedUri),
            xnote = getXnote(parsedUri),
            mnemonic = getMnemonic(parsedUri),
            label = getLabel(parsedUri),
            transactionId = getTransactionId(parsedUri),
            transactionStatus = getTransactionStatus(parsedUri),
            webImportQrCode = getWebImportData(parsedUri),
            notificationGroupType = getNotificationGroupType(parsedUri)
        )
    }

    private fun getXnote(parsedUri: Uri): String? {
        return parseQueryIfExist(XNOTE_QUERY_KEY, parsedUri)
    }

    private fun getNote(parsedUri: Uri): String? {
        return parseQueryIfExist(NOTE_QUERY_KEY, parsedUri)
    }

    private fun getAmount(parsedUri: Uri): BigInteger? {
        val amountAsString = parseQueryIfExist(AMOUNT_QUERY_KEY, parsedUri)
        return amountAsString?.toBigIntegerOrNull()
    }

    private fun getAssetId(parsedUri: Uri): Long? {
        val assetIdAsString = when {
            isCoinbaseLink(parsedUri) -> getAssetIdForCoinbase(parsedUri.toString())
            else -> parseQueryIfExist(ASSET_ID_QUERY_KEY, parsedUri)
        }
        return assetIdAsString?.toLongOrNull()
    }

    private fun getLabel(parsedUri: Uri): String? {
        return parseQueryIfExist(LABEL_QUERY_KEY, parsedUri)
    }

    private fun getTransactionId(parsedUri: Uri): String? {
        return parseQueryIfExist(TRANSACTION_ID_KEY, parsedUri)
    }

    private fun getTransactionStatus(parsedUri: Uri): String? {
        return parseQueryIfExist(TRANSACTION_STATUS_KEY, parsedUri)
    }

    private fun getAccountAddress(uri: Uri): String? {
        return when {
            isApplink(uri) -> uri.path
                ?.split(PATH_SEPARATOR)
                ?.firstOrNull { it.isValidAddress() }

            isCoinbaseLink(uri) -> getAccountAddressForCoinbase(uri.toString())
            else -> parseQueryIfExist(ACCOUNT_ID_QUERY_KEY, uri) ?: uri.authority
        }?.takeIf { it.isValidAddress() } ?: uri.toString().takeIf { it.isValidAddress() }
    }

    private fun getWalletConnectUrl(uri: Uri): String? {
        return with(uri) {
            val parsedUrl = if (isApplink(this)) {
                val walletConnectUrl = toString().split(PERAWALLET_WC_AUTH_KEY).lastOrNull()
                walletConnectUrl?.removePrefix(PATH_SEPARATOR)
            } else {
                if (authority.isNullOrBlank()) {
                    uri.toString()
                } else {
                    removeAuthSeparator(schemeSpecificPart)
                }
            }
            parsedUrl.takeIf { it?.startsWith(WALLET_CONNECT_AUTH_KEY) == true }
        }
    }

    private fun getMnemonic(uri: Uri): String? {
        return try {
            moshi.fromJson<RawMnemonicPayload>(uri.toString())?.mnemonic
        } catch (exception: Exception) {
            null
        }
    }

    private fun getWebImportData(uri: Uri): WebImportQrCode? {
        return try {
            moshi.fromJson<WebQrCode>(uri.toString())?.let { qrCode ->
                webImportQrCodeMapper.mapFromWebQrCode(qrCode)
            }
        } catch (exception: Exception) {
            null
        }
    }

    private fun getNotificationGroupType(uri: Uri): NotificationGroupType? {
        return with(uri) {
            when (authority + path) {
                NOTIFICATION_ACTION_ASSET_TRANSACTIONS -> NotificationGroupType.TRANSACTIONS
                NOTIFICATION_ACTION_ASSET_OPTIN -> NotificationGroupType.OPT_IN
                else -> null
            }
        }
    }

    private fun parseQueryIfExist(queryKey: String, uri: Uri): String? {
        if (!uri.isHierarchical) return null
        val hasQueryKey = uri.queryParameterNames.contains(queryKey)
        return if (hasQueryKey) uri.getQueryParameter(queryKey) else null
    }

    private fun isApplink(uri: Uri): Boolean {
        return removeAuthSeparator(uri.schemeSpecificPart).startsWith(PERAWALLET_APPLINK_AUTH_KEY)
    }

    private fun isCoinbaseLink(uri: Uri): Boolean {
        return uri.scheme.equals(COINBASE_DEEPLINK_ROOT, ignoreCase = true)
    }

    private fun removeAuthSeparator(uriString: String): String {
        return uriString.removePrefix(AUTH_SEPARATOR)
    }

    fun getAccountAddressForCoinbase(url: String): String? {
        // algo:31566704/transfer?address=KG2HXWIOQSBOBGJEXSIBNEVNTRD4G4EFIJGRKBG2ZOT7NQ
        val regexAddress = COINBASE_ACCOUNT_ADDRESS_WITH_ASSET_ID_REGEX.toRegex()
        val matchResultWithAddress = regexAddress.find(url)
        if (matchResultWithAddress != null) {
            return matchResultWithAddress.destructured.component1()
        }

        // algo:Z7HJOZWPBM76GNERLD56IUMNMA7TNFMERU4KSDDXLUYGFBRLLVVGKGULCE
        val regexWithoutAssetId = COINBASE_ACCOUNT_ADDRESS_REGEX.toRegex()
        val matchResultWithoutAssetId = regexWithoutAssetId.find(url)
        if (matchResultWithoutAssetId != null) {
            return matchResultWithoutAssetId.destructured.component1()
        }
        return null
    }

    fun getAssetIdForCoinbase(url: String): String? {
        // algo:31566704/transfer?address=KG2HXWIOQSBOBGJEXSIBNEVNTRD4G4EFIJGRKBG2ZOT7NQ
        val regexWithAssetId = COINBASE_ASSET_ID_REGEX.toRegex()
        val matchResultWithAssetId = regexWithAssetId.find(url)
        if (matchResultWithAssetId != null) {
            return matchResultWithAssetId.destructured.component1()
        } else {
            return ALGO_ID.toString()
        }
    }

    companion object {
        private const val PERAWALLET_APPLINK_AUTH_KEY = "perawallet.app"
        private const val COINBASE_DEEPLINK_ROOT = "algo"

        private const val PERAWALLET_WC_AUTH_KEY = "perawallet-wc"
        private const val WALLET_CONNECT_AUTH_KEY = "wc"

        private const val AMOUNT_QUERY_KEY = "amount"
        private const val ASSET_ID_QUERY_KEY = "asset"
        private const val ACCOUNT_ID_QUERY_KEY = "account"
        private const val NOTE_QUERY_KEY = "note"
        private const val XNOTE_QUERY_KEY = "xnote"
        private const val LABEL_QUERY_KEY = "label"
        private const val TRANSACTION_ID_KEY = "transactionId"
        private const val TRANSACTION_STATUS_KEY = "transactionStatus"
        private const val NOTIFICATION_ACTION_ASSET_TRANSACTIONS = "asset/transactions"
        private const val NOTIFICATION_ACTION_ASSET_OPTIN = "asset/opt-in"

        private const val COINBASE_ACCOUNT_ADDRESS_WITH_ASSET_ID_REGEX = """address=([A-Z0-9]+)"""
        private const val COINBASE_ACCOUNT_ADDRESS_REGEX = """algo:([A-Z0-9]+)"""
        private const val COINBASE_ASSET_ID_REGEX = """algo:(\d+)"""

        private const val AUTH_SEPARATOR = "//"
        private const val PATH_SEPARATOR = "/"
    }
}
