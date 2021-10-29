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

package com.algorand.android.ui.wctransactionrequest

import android.content.SharedPreferences
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account.Type.LEDGER
import com.algorand.android.models.Account.Type.REKEYED
import com.algorand.android.models.Account.Type.REKEYED_AUTH
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.WalletConnectSignResult
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.preference.getFirstWalletConnectRequestBottomSheetShown
import com.algorand.android.utils.preference.setFirstWalletConnectRequestBottomSheetShown
import com.algorand.android.utils.walletconnect.WalletConnectManager
import com.algorand.android.utils.walletconnect.WalletConnectSignManager
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import kotlinx.coroutines.launch

class WalletConnectTransactionRequestViewModel @ViewModelInject constructor(
    private val walletConnectManager: WalletConnectManager,
    private val errorProvider: WalletConnectTransactionErrorProvider,
    private val sharedPreferences: SharedPreferences,
    private val walletConnectSignManager: WalletConnectSignManager
) : BaseViewModel() {

    val requestResultLiveData: LiveData<Event<Resource<AnnotatedString>>>
        get() = walletConnectManager.requestResultLiveData

    val signResultLiveData: LiveData<WalletConnectSignResult>
        get() = walletConnectSignManager.signResultLiveData

    fun setupWalletConnectSignManager(lifecycle: Lifecycle) {
        walletConnectSignManager.setup(lifecycle)
    }

    fun rejectRequest(sessionId: Long, requestId: Long) {
        walletConnectManager.rejectRequest(sessionId, requestId, errorProvider.rejected.userRejection)
    }

    fun shouldShowFirstRequestBottomSheet(): Boolean {
        return !sharedPreferences.getFirstWalletConnectRequestBottomSheetShown().also {
            sharedPreferences.setFirstWalletConnectRequestBottomSheetShown()
        }
    }

    fun signTransactionRequest(transaction: WalletConnectTransaction) {
        viewModelScope.launch {
            walletConnectSignManager.signTransaction(transaction)
        }
    }

    fun processWalletConnectSignResult(result: WalletConnectSignResult) {
        walletConnectManager.processWalletConnectSignResult(result)
    }

    fun stopAllResources() {
        walletConnectSignManager.manualStopAllResources()
    }

    fun isBluetoothNeededToSignTxns(transaction: WalletConnectTransaction): Boolean {
        return transaction.transactionList.flatten().any {
            val accountDetail = it.accountCacheData?.account?.type ?: return false
            accountDetail == LEDGER || accountDetail == REKEYED || accountDetail == REKEYED_AUTH
        }
    }
}
