@file:Suppress("TooManyFunctions")

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
import com.algorand.algosdk.sdk.BytesArray
import com.algorand.algosdk.sdk.Encryption
import com.algorand.algosdk.sdk.Sdk
import com.algorand.algosdk.sdk.SuggestedParams
import com.algorand.algosdk.sdk.Uint64
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.TransactionParams
import java.io.ByteArrayOutputStream
import java.math.BigInteger

const val ENCRYPTION_SEPARATOR_CHAR = ","
const val SDK_RESULT_SUCCESS = 0L
const val SDK_RESULT_ERROR_INVALID_SECRET_KEY = 1L
const val SDK_RESULT_ERROR_RANDOM_GENERATOR_ERROR_KEY = 2L
const val SDK_RESULT_ERROR_INVALID_ENCRYPTED_DATA_LENGTH_KEY = 3L
const val SDK_RESULT_ERROR_DECRYPTION_ERROR_LENGTH_KEY = 4L

fun ByteArray.signTx(secretKey: ByteArray): ByteArray {
    return Sdk.signTransaction(secretKey, this)
}

fun ByteArray.signArbitraryData(secretKey: ByteArray): ByteArray {
    return Sdk.signBytes(secretKey, this)
}

fun TransactionParams.makeAssetTx(
    senderAddress: String,
    receiverAddress: String,
    amount: BigInteger,
    assetId: Long,
    noteInByteArray: ByteArray? = null
): ByteArray {
    return Sdk.makeAssetTransferTxn(
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
    return Sdk.makePaymentTxn(
        senderAddress,
        receiverAddress,
        amount.toUint64(),
        noteInByteArray,
        if (isMax) receiverAddress else "",
        toSuggestedParams()
    )
}

fun TransactionParams.makeRekeyTx(rekeyAddress: String, rekeyAdminAddress: String): ByteArray {
    return Sdk.makeRekeyTxn(
        rekeyAddress,
        rekeyAdminAddress,
        toSuggestedParams()
    )
}

fun TransactionParams.makeAddAssetTx(publicKey: String, assetId: Long): ByteArray {
    return Sdk.makeAssetAcceptanceTxn(
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
    return Sdk.makeAssetTransferTxn(
        senderAddress,
        creatorPublicKey,
        creatorPublicKey,
        0L.toUint64(),
        null,
        toSuggestedParams(addGenesisId = false),
        assetId
    )
}

fun TransactionParams.makeSendAndRemoveAssetTx(
    senderAddress: String,
    receiverAddress: String,
    assetId: Long,
    amount: BigInteger,
    noteInByteArray: ByteArray? = null
): ByteArray {
    return Sdk.makeAssetTransferTxn(
        senderAddress,
        receiverAddress,
        receiverAddress,
        amount.toUint64(),
        noteInByteArray,
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

    return if (assetId == AssetInformation.ALGO_ID) {
        makeAlgoTx(senderAddress, receiverAddress, amount, isMax, noteInByteArray)
    } else {
        makeAssetTx(senderAddress, receiverAddress, amount, assetId, noteInByteArray)
    }
}

fun TransactionParams.getTxFee(signedTxData: ByteArray? = null): Long {
    return ((signedTxData?.size ?: DATA_SIZE_FOR_MAX) * fee).coerceAtLeast(minFee ?: MIN_FEE)
}

fun String?.isValidAddress(): Boolean {
    if (isNullOrBlank()) {
        return false
    }
    return try {
        Sdk.isValidAddress(this)
    } catch (exception: Exception) {
        recordException(exception)
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

fun getPublicKey(publicKey: ByteArray): String? {
    return try {
        Sdk.generateAddressFromPublicKey(publicKey)
    } catch (exception: Exception) {
        recordException(exception)
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
        Sdk.transactionMsgpackToJson(decodedByteArray)
    } catch (exception: Exception) {
        recordException(exception)
        ""
    }
}

fun generateAddressFromProgram(hashValue: String?): String {
    return try {
        val decodedByteArray = Base64.decode(hashValue, Base64.DEFAULT)
        Sdk.addressFromProgram(decodedByteArray)
    } catch (exception: Exception) {
        recordException(exception)
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
): List<List<BaseWalletConnectTransaction>>? {
    val decodedTxnList = txnList.map { Base64.decode(it.rawTransactionPayload.transactionMsgPack, Base64.DEFAULT) }
    val decodedTxnBytesArray = BytesArray().apply {
        decodedTxnList.forEach { append(it) }
    }
    return try {
        val txnGroupInt64Array = Sdk.findAndVerifyTxnGroups(decodedTxnBytesArray)
        val txnGroupList = mutableListOf<Pair<Long, BaseWalletConnectTransaction>>().apply {
            for (index in 0L until txnGroupInt64Array.length()) {
                add(txnGroupInt64Array.get(index) to txnList[index.toInt()])
            }
        }
        txnGroupList.groupBy { it.first }.map { it.value.map { it.second } }
    } catch (e: Exception) {
        null
    }
}

fun getTransactionId(txnByteArray: ByteArray?): String {
    return try {
        Sdk.getTxID(txnByteArray)
    } catch (exception: Exception) {
        recordException(exception)
        ""
    }
}

fun List<ByteArray>.toBytesArray(): BytesArray {
    return BytesArray().apply {
        this@toBytesArray.forEach {
            append(it)
        }
    }
}

// TODO: 1.06.2022 Create a wrapper for grouped BytesArray so that we can distinguish between them
fun BytesArray.assignGroupId(): BytesArray {
    return Sdk.assignGroupID(this)
}

fun List<ByteArray>.flatten(): ByteArray {
    return ByteArrayOutputStream().apply {
        this@flatten.forEach { write(it) }
    }.toByteArray()
}

fun ByteArray.encrypt(secretKey: ByteArray): Encryption {
    return Sdk.encrypt(this, secretKey)
}

fun ByteArray.decrypt(secretKey: ByteArray): Encryption {
    return Sdk.decrypt(this, secretKey)
}
