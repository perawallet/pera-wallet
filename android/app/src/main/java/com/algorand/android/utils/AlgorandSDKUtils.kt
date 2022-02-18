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

import android.util.Base64
import com.algorand.algosdk.mobile.BytesArray
import com.algorand.algosdk.mobile.Mobile
import com.algorand.algosdk.mobile.SuggestedParams
import com.algorand.algosdk.mobile.Uint64
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.TransactionParams
import com.google.firebase.crashlytics.FirebaseCrashlytics
import java.math.BigInteger

fun ByteArray.signTx(secretKey: ByteArray): ByteArray {
    return Mobile.signTransaction(secretKey, this)
}

fun TransactionParams.makeAssetTx(
    senderAddress: String,
    receiverAddress: String,
    amount: BigInteger,
    assetId: Long,
    noteInByteArray: ByteArray? = null
): ByteArray {

    return Mobile.makeAssetTransferTxn(
        senderAddress,
        receiverAddress,
        "",
        amount.toUint64(),
        noteInByteArray,
        toSuggestedParams(addGenesisId = false),
        assetId
    )
}

fun TransactionParams.makeAlgoTx(
    senderAddress: String,
    receiverAddress: String,
    amount: BigInteger,
    isMax: Boolean,
    noteInByteArray: ByteArray? = null
): ByteArray {
    return Mobile.makePaymentTxn(
        senderAddress,
        receiverAddress,
        amount.toUint64(),
        noteInByteArray,
        if (isMax) receiverAddress else "",
        toSuggestedParams()
    )
}

fun TransactionParams.makeRekeyTx(rekeyAddress: String, rekeyAdminAddress: String): ByteArray {
    return Mobile.makeRekeyTxn(
        rekeyAddress,
        rekeyAdminAddress,
        toSuggestedParams()
    )
}

fun TransactionParams.makeAddAssetTx(publicKey: String, assetId: Long): ByteArray {
    return Mobile.makeAssetAcceptanceTxn(
        publicKey,
        null,
        toSuggestedParams(),
        assetId
    )
}

fun TransactionParams.makeRemoveAssetTx(
    senderAddress: String,
    creatorPublicKey: String,
    assetId: Long
): ByteArray {
    return Mobile.makeAssetTransferTxn(
        senderAddress,
        creatorPublicKey,
        creatorPublicKey,
        0L.toUint64(),
        null,
        toSuggestedParams(addGenesisId = false),
        assetId
    )
}

fun TransactionParams.makeTx(
    senderAddress: String,
    receiverAddress: String,
    amount: BigInteger,
    assetId: Long,
    isMax: Boolean,
    note: String? = null
): ByteArray {
    val noteInByteArray = note?.toByteArray(charset = Charsets.UTF_8)

    return if (assetId == AssetInformation.ALGORAND_ID) {
        makeAlgoTx(senderAddress, receiverAddress, amount, isMax, noteInByteArray)
    } else {
        makeAssetTx(senderAddress, receiverAddress, amount, assetId, noteInByteArray)
    }
}

fun TransactionParams.getTxFee(signedTxData: ByteArray? = null): Long {
    return ((signedTxData?.size ?: DATA_SIZE_FOR_MAX) * fee).coerceAtLeast(MIN_FEE)
}

fun String?.isValidAddress(): Boolean {
    if (isNullOrBlank()) {
        return false
    }
    return try {
        Mobile.isValidAddress(this)
    } catch (exception: Exception) {
        FirebaseCrashlytics.getInstance().recordException(exception)
        false
    }
}

fun TransactionParams.toSuggestedParams(
    addGenesisId: Boolean = true
): SuggestedParams {
    return SuggestedParams().apply {
        fee = this@toSuggestedParams.fee
        genesisID = if (addGenesisId) genesisId else ""
        firstRoundValid = lastRound
        lastRoundValid = lastRound + ROUND_THRESHOLD
        genesisHash = Base64.decode(this@toSuggestedParams.genesisHash, Base64.DEFAULT)
    }
}

fun getPublicKey(addressAsByteArray: ByteArray): String? {
    return try {
        Mobile.generateAddressFromPublicKey(addressAsByteArray)
    } catch (exception: Exception) {
        FirebaseCrashlytics.getInstance().recordException(exception)
        null
    }
}

fun getBase64DecodedPublicKey(address: String?): String? {
    if (address == null) return null
    return getPublicKey(Base64.decode(address, Base64.DEFAULT))
}

fun Long.toUint64(): Uint64 {
    return Uint64().apply {
        upper = shr(Int.SIZE_BITS)
        lower = and(Int.MAX_VALUE.toLong())
    }
}

fun BigInteger.toUint64(): Uint64 {
    return Uint64().apply {
        upper = shr(Int.SIZE_BITS).toLong()
        lower = and(UInt.MAX_VALUE.toLong().toBigInteger()).toLong()
    }
}

fun decodeBase64DecodedMsgPackToJsonString(msgPack: String): String {
    return try {
        val decodedByteArray = Base64.decode(msgPack, Base64.DEFAULT)
        Mobile.transactionMsgpackToJson(decodedByteArray)
    } catch (exception: Exception) {
        FirebaseCrashlytics.getInstance().recordException(exception)
        ""
    }
}

fun generateAddressFromProgram(hashValue: String?): String {
    return try {
        val decodedByteArray = Base64.decode(hashValue, Base64.DEFAULT)
        Mobile.addressFromProgram(decodedByteArray)
    } catch (exception: Exception) {
        ""
    }
}

/**
 * txnGroupList is a pair list that keeps group id and transaction
 * i.e= listOf(
 *      Pair(0, A_1),
 *      Pair(0, A_2),
 *      Pair(1, B_1),
 *      Pair(1, B_2),
 *      Pair(1, B_3)
 *  )
 *
 *  By calling; txnGroupList.groupBy { it.first }.map { it.value.map { it.second } }
 *  it creates map that keeps group ids as key and txns as values;
 *      {0=[(0, A_1), (0, A_2)], 1=[(1, B_1), (1, B_2), (1, B_3)]}
 *  then converts it to nested list
 *      [[A_1, A_2], [B_1, B_2, B_3]]
 */
fun groupWalletConnectTransactions(
    txnList: List<BaseWalletConnectTransaction>
): List<List<BaseWalletConnectTransaction>> {
    val decodedTxnList = txnList.map { Base64.decode(it.rawTransactionPayload.transactionMsgPack, Base64.DEFAULT) }
    val decodedTxnBytesArray = BytesArray().apply {
        decodedTxnList.forEach { append(it) }
    }
    val txnGroupInt64Array = Mobile.findAndVerifyTxnGroups(decodedTxnBytesArray)
    val txnGroupList = mutableListOf<Pair<Long, BaseWalletConnectTransaction>>().apply {
        for (index in 0L until txnGroupInt64Array.length()) {
            add(txnGroupInt64Array.get(index) to txnList[index.toInt()])
        }
    }
    return txnGroupList.groupBy { it.first }.map { it.value.map { it.second } }
}

fun getTransactionId(txnByteArray: ByteArray?): String {
    return try {
        Mobile.getTxID(txnByteArray)
    } catch (exception: Exception) {
        FirebaseCrashlytics.getInstance().recordException(exception)
        ""
    }
}
