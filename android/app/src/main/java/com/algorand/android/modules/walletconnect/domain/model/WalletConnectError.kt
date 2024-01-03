package com.algorand.android.modules.walletconnect.domain.model

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class WalletConnectError(
    val message: String,
    val errorCategory: String,
    val reason: WalletConnectErrorReason
) : Parcelable
