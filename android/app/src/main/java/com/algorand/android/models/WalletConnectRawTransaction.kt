package com.algorand.android.models

import com.google.gson.annotations.SerializedName

data class WalletConnectRawTransaction(
    @SerializedName("txn")
    val rawTransactionRequest: DecodedWalletConnectTransactionRequest,
    @SerializedName("signer")
    val signers: List<String>? = null
)
