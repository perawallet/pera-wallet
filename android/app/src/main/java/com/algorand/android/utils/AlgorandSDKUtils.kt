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

import android.util.Base64
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.TransactionParams
import com.google.firebase.crashlytics.FirebaseCrashlytics
import crypto.Crypto
import transaction.Transaction
import utils.Utils

fun ByteArray.signTx(secretKey: ByteArray): ByteArray {
    return Crypto.signTransaction(secretKey, this)
}

fun TransactionParams.makeAssetTx(
    senderAddress: String,
    receiverAddress: String,
    amount: Long,
    assetId: Long,
    noteInByteArray: ByteArray? = null
): ByteArray {
    return Transaction.makeAssetTransferTxn(
        senderAddress,
        receiverAddress,
        "",
        amount,
        fee,
        lastRound,
        lastRound + ROUND_THRESHOLD,
        noteInByteArray,
        "",
        genesisHash,
        assetId
    )
}

fun TransactionParams.makeAlgoTx(
    senderAddress: String,
    receiverAddress: String,
    amount: Long,
    isMax: Boolean,
    noteInByteArray: ByteArray? = null
): ByteArray {
    return Transaction.makePaymentTxn(
        senderAddress,
        receiverAddress,
        fee,
        amount,
        lastRound,
        lastRound + ROUND_THRESHOLD,
        noteInByteArray,
        if (isMax) receiverAddress else "",
        genesisId,
        Base64.decode(genesisHash, Base64.DEFAULT)
    )
}

fun TransactionParams.makeRekeyTx(rekeyAddress: String, rekeyAdminAddress: String): ByteArray {
    return Transaction.makeRekeyTxn(
        rekeyAddress,
        rekeyAdminAddress,
        fee,
        lastRound,
        lastRound + ROUND_THRESHOLD,
        genesisId,
        Base64.decode(genesisHash, Base64.DEFAULT)
    )
}

fun TransactionParams.makeAddAssetTx(publicKey: String, assetId: Long): ByteArray {
    return Transaction.makeAssetAcceptanceTxn(
        publicKey,
        fee,
        lastRound,
        lastRound + ROUND_THRESHOLD,
        null,
        genesisId,
        genesisHash,
        assetId
    )
}

fun TransactionParams.makeRemoveAssetTx(
    senderAddress: String,
    creatorPublicKey: String,
    assetId: Long
): ByteArray {
    return Transaction.makeAssetTransferTxn(
        senderAddress,
        creatorPublicKey,
        creatorPublicKey,
        0,
        fee,
        lastRound,
        lastRound + ROUND_THRESHOLD,
        null,
        "",
        genesisHash,
        assetId
    )
}

fun TransactionParams.makeTx(
    senderAddress: String,
    receiverAddress: String,
    amount: Long,
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
        Utils.isValidAddress(this)
    } catch (exception: Exception) {
        FirebaseCrashlytics.getInstance().recordException(exception)
        false
    }
}

fun getPublicKey(addressAsByteArray: ByteArray): String? {
    return try {
        Crypto.generateAddressFromPublicKey(addressAsByteArray)
    } catch (exception: Exception) {
        FirebaseCrashlytics.getInstance().recordException(exception)
        null
    }
}
