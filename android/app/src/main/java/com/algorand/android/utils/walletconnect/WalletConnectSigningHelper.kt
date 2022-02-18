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

package com.algorand.android.utils.walletconnect

import com.algorand.android.models.BaseWalletConnectTransaction
import javax.inject.Inject
import kotlin.properties.Delegates

class WalletConnectSigningHelper @Inject constructor() {

    val currentTransaction: BaseWalletConnectTransaction?
        get() = _currentTransaction

    private val signedTransactionList = mutableListOf<ByteArray?>()
    private var transactionCount = -1
    private val transactionsToBeSigned = mutableListOf<BaseWalletConnectTransaction>()
    private var _currentTransaction: BaseWalletConnectTransaction? by Delegates.observable(null) { _, _, newValue ->
        if (newValue != null) listener?.onNextTransactionToSign(newValue)
    }

    private var listener: Listener? = null

    private val areAllTransactionsSigned: Boolean
        get() = transactionCount == signedTransactionList.size && transactionCount != -1

    fun initListener(listener: Listener) {
        this.listener = listener
    }

    fun initTransactionsToBeSigned(transactionList: List<List<BaseWalletConnectTransaction>>) {
        clearCachedData()
        transactionsToBeSigned.addAll(transactionList.flatten())
        transactionCount = transactionsToBeSigned.size
        setCurrentTransaction()
    }

    fun cacheSignedTransaction(transactionByteArray: ByteArray?) {
        signedTransactionList.add(transactionByteArray)
        if (areAllTransactionsSigned) {
            listener?.onTransactionSignCompleted(signedTransactionList.toList())
            clearCachedData()
            return
        }
        setCurrentTransaction()
    }

    private fun setCurrentTransaction() {
        _currentTransaction = transactionsToBeSigned.removeFirstOrNull()
    }

    fun clearCachedData() {
        signedTransactionList.clear()
        transactionsToBeSigned.clear()
        transactionCount = -1
        _currentTransaction = null
    }

    interface Listener {
        fun onTransactionSignCompleted(signedTransactions: List<ByteArray?>)
        fun onNextTransactionToSign(transaction: BaseWalletConnectTransaction)
    }
}
