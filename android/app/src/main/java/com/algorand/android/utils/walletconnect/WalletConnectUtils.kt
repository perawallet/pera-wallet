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

package com.algorand.android.utils.walletconnect

import android.util.Base64
import androidx.navigation.NavDirections
import com.algorand.android.R
import com.algorand.android.WalletConnectRequestNavigationDirections.Companion.actionGlobalWalletConnectAssetConfigurationTransactionFragment
import com.algorand.android.WalletConnectRequestNavigationDirections.Companion.actionWalletConnectTransactionRequestFragmentToWalletConnectAppCallTransactionFragment
import com.algorand.android.WalletConnectRequestNavigationDirections.Companion.actionWalletConnectTransactionRequestFragmentToWalletConnectAssetTransactionFragment
import com.algorand.android.WalletConnectRequestNavigationDirections.Companion.actionWalletConnectTransactionRequestFragmentToWalletConnectPaymentTransactionFragment
import com.algorand.android.models.BaseAppCallTransaction
import com.algorand.android.models.BaseAssetConfigurationTransaction
import com.algorand.android.models.BaseAssetTransferTransaction
import com.algorand.android.models.BasePaymentTransaction
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.models.WalletConnectTransactionRequest
import com.algorand.android.utils.decodeBase64
import com.algorand.android.utils.decodeBase64DecodedMsgPackToJsonString
import com.algorand.android.utils.getTransactionId
import com.algorand.android.utils.signTx
import com.google.crypto.tink.subtle.Hex
import com.google.gson.Gson
import org.walletconnect.Session

const val WALLET_CONNECT_URL_PREFIX = "wc:"
private const val FUTURE_TRANSACTION_WARNING_THRESHOLD = 500L

private val placeholderIconResIdList = listOf(
    R.drawable.ic_peer_meta_placeholder_1,
    R.drawable.ic_peer_meta_placeholder_2,
    R.drawable.ic_peer_meta_placeholder_3,
    R.drawable.ic_peer_meta_placeholder_4
)

// TODO add more check if possible (bridge and key)
fun isValidWalletConnectUrl(url: String): Boolean {
    return url.startsWith(WALLET_CONNECT_URL_PREFIX) && createSessionConfigFromUrl(url) != null
}

fun createSessionConfigFromUrl(url: String): Session.Config? {
    return try {
        Session.Config.fromWCUri(url)
    } catch (exception: Exception) {
        null
    }
}

fun createFullyQualifiedSessionConfig(sessionConfig: Session.Config): Session.FullyQualifiedConfig? {
    return try {
        sessionConfig.toFullyQualifiedConfig()
    } catch (exception: Exception) {
        null
    }
}

fun WCAlgoTransactionRequest.getTransactionRequest(gson: Gson): WalletConnectTransactionRequest {
    val transactionJson = decodeBase64DecodedMsgPackToJsonString(transactionMsgPack)
    return gson.fromJson(transactionJson, WalletConnectTransactionRequest::class.java)
}

fun BaseWalletConnectTransaction.signTransaction(secretKey: ByteArray): ByteArray? {
    return decodedTransaction?.signTx(secretKey)
}

fun getRandomPeerMetaIconResId() = placeholderIconResIdList.random()

fun decodeBase64ToString(text: String?): String {
    return try {
        String(Base64.decode(text, Base64.DEFAULT))
    } catch (exception: Exception) {
        ""
    }
}

fun encodeBase64EncodedHexString(text: String?): String? {
    return try {
        Hex.encode(text?.decodeBase64())
    } catch (exception: Exception) {
        null
    }
}

fun getWalletConnectTransactionRequestDirection(transaction: BaseWalletConnectTransaction): NavDirections? {
    // TODO: 28.09.2021 We should move this into their model class
    return when (transaction) {
        is BasePaymentTransaction -> {
            actionWalletConnectTransactionRequestFragmentToWalletConnectPaymentTransactionFragment(transaction)
        }
        is BaseAssetTransferTransaction -> {
            actionWalletConnectTransactionRequestFragmentToWalletConnectAssetTransactionFragment(transaction)
        }
        is BaseAppCallTransaction -> {
            actionWalletConnectTransactionRequestFragmentToWalletConnectAppCallTransactionFragment(transaction)
        }
        is BaseAssetConfigurationTransaction -> {
            actionGlobalWalletConnectAssetConfigurationTransactionFragment(transaction)
        }
        else -> null
    }
}

fun WalletConnectTransaction.getTransactionIds(): List<String> {
    return transactionList.flatten().map { getTransactionId(it.decodedTransaction) }
}

fun WalletConnectTransaction.getTransactionCount(): Int {
    return transactionList.flatten().size
}

fun WalletConnectTransaction.isFutureTransaction(): Boolean {
    return transactionList.flatten().any {
        if (it.requestedBlockCurrentRound == -1L) return false
        val warningThreshold = it.requestedBlockCurrentRound + FUTURE_TRANSACTION_WARNING_THRESHOLD
        val firstValidRound = it.walletConnectTransactionParams.firstValidRound
        return if (firstValidRound == null) false else firstValidRound > warningThreshold
    }
}
