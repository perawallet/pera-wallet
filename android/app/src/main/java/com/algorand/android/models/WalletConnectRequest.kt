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

package com.algorand.android.models

import android.os.Parcelable
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import kotlinx.parcelize.Parcelize

sealed class WalletConnectRequest : Parcelable {
    abstract val requestId: Long
    abstract val session: WalletConnectSession
    abstract val versionIdentifier: WalletConnectVersionIdentifier

    abstract fun getListSize(): Int

    @Parcelize
    data class WalletConnectTransaction(
        override val requestId: Long,
        override val session: WalletConnectSession,
        override val versionIdentifier: WalletConnectVersionIdentifier,
        val message: String?,
        val transactionList: List<List<BaseWalletConnectTransaction>>
    ) : WalletConnectRequest() {
        override fun getListSize(): Int = transactionList.size
    }

    @Parcelize
    data class WalletConnectArbitraryDataRequest(
        override val requestId: Long,
        override val session: WalletConnectSession,
        override val versionIdentifier: WalletConnectVersionIdentifier,
        val arbitraryDataList: List<WalletConnectArbitraryData>,
    ) : WalletConnectRequest() {
        override fun getListSize(): Int = arbitraryDataList.size
    }
}
