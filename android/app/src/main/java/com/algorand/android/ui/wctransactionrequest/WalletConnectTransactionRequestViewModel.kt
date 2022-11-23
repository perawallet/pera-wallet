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

package com.algorand.android.ui.wctransactionrequest

import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.R
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account.Type.LEDGER
import com.algorand.android.models.Account.Type.REKEYED
import com.algorand.android.models.Account.Type.REKEYED_AUTH
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WalletConnectSignResult
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.models.builder.WalletConnectTransactionListBuilder
import com.algorand.android.modules.walletconnect.transactionrequest.ui.model.WalletConnectTransactionRequestPreview
import com.algorand.android.modules.walletconnect.transactionrequest.ui.usecase.WalletConnectTransactionRequestPreviewUseCase
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.usecase.GetInstalledAppPackageNameListUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.preference.getFirstWalletConnectRequestBottomSheetShown
import com.algorand.android.utils.preference.setFirstWalletConnectRequestBottomSheetShown
import com.algorand.android.utils.walletconnect.WalletConnectManager
import com.algorand.android.utils.walletconnect.WalletConnectSignManager
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class WalletConnectTransactionRequestViewModel @Inject constructor(
    private val walletConnectManager: WalletConnectManager,
    private val errorProvider: WalletConnectTransactionErrorProvider,
    private val sharedPreferences: SharedPreferences,
    private val walletConnectSignManager: WalletConnectSignManager,
    private val transactionListBuilder: WalletConnectTransactionListBuilder,
    private val getInstalledAppPackageNameListUseCase: GetInstalledAppPackageNameListUseCase,
    private val walletConnectTransactionRequestPreviewUseCase: WalletConnectTransactionRequestPreviewUseCase
) : BaseViewModel() {

    val requestResultLiveData: LiveData<Event<Resource<AnnotatedString>>>
        get() = walletConnectManager.requestResultLiveData

    val signResultLiveData: LiveData<WalletConnectSignResult>
        get() = walletConnectSignManager.signResultLiveData

    val transaction: WalletConnectTransaction?
        get() = walletConnectManager.transaction

    val walletConnectTransactionRequestPreviewFlow: StateFlow<WalletConnectTransactionRequestPreview>
        get() = _walletConnectTransactionRequestPreviewFlow
    private val _walletConnectTransactionRequestPreviewFlow = MutableStateFlow(
        walletConnectTransactionRequestPreviewUseCase.getInitialPreview(transaction?.session?.peerMeta?.name.orEmpty())
    )

    fun setupWalletConnectSignManager(lifecycle: Lifecycle) {
        walletConnectSignManager.setup(lifecycle)
    }

    fun rejectRequest() {
        transaction?.let {
            walletConnectManager.rejectRequest(it.session.id, it.requestId, errorProvider.rejected.userRejection)
        }
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
            val accountDetail = it.fromAccount?.type ?: return false
            accountDetail == LEDGER || accountDetail == REKEYED || accountDetail == REKEYED_AUTH
        }
    }

    fun handleStartDestinationAndArgs(transactionList: List<WalletConnectTransactionListItem>): Pair<Int, Bundle?> {
        val startDestination = if (
            transactionList.count() == 1 &&
            transactionList.first() is WalletConnectTransactionListItem.SingleTransactionItem
        ) {
            R.id.walletConnectSingleTransactionFragment
        } else {
            R.id.walletConnectMultipleTransactionFragment
        }

        val startDestinationArgs = when (startDestination) {
            R.id.walletConnectSingleTransactionFragment -> {
                Bundle().apply { putParcelable(SINGLE_TRANSACTION_KEY, transactionList.first()) }
            }
            R.id.walletConnectMultipleTransactionFragment -> {
                Bundle().apply { putParcelableArray(MULTIPLE_TRANSACTION_KEY, transactionList.toTypedArray()) }
            }
            else -> null
        }

        return Pair(startDestination, startDestinationArgs)
    }

    fun createTransactionListItems(
        transactionList: List<List<BaseWalletConnectTransaction>>
    ): List<WalletConnectTransactionListItem> {
        return transactionListBuilder.createTransactionItems(transactionList)
    }

    fun updatePreviewWithBrowserList(packageManager: PackageManager?) {
        viewModelScope.launch {
            _walletConnectTransactionRequestPreviewFlow.emit(
                walletConnectTransactionRequestPreviewUseCase
                    .getWalletConnectTransactionRequestPreviewByBrowserResponse(
                        preview = _walletConnectTransactionRequestPreviewFlow.value,
                        fallbackBrowserGroupResponse = transaction?.session?.fallbackBrowserGroupResponse,
                        packageManager = packageManager
                    )
            )
        }
    }

    companion object {
        private const val MULTIPLE_TRANSACTION_KEY = "transactions"
        private const val SINGLE_TRANSACTION_KEY = "transaction"
    }
}
