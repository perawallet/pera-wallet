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

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.algorand.android.models.Account
import com.algorand.android.models.Account.Detail.Rekeyed
import com.algorand.android.models.Account.Detail.RekeyedAuth
import com.algorand.android.models.Account.Detail.Standard
import com.algorand.android.models.WalletConnectArbitraryData
import com.algorand.android.models.WalletConnectRequest.WalletConnectArbitraryDataRequest
import com.algorand.android.models.WalletConnectSignResult
import com.algorand.android.models.WalletConnectSignResult.Success
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.LifecycleScopedCoroutineOwner
import com.algorand.android.utils.ListQueuingHelper
import com.algorand.android.utils.sendErrorLog
import com.algorand.android.utils.signArbitraryData
import javax.inject.Inject
import kotlinx.coroutines.cancelChildren

class WalletConnectArbitraryDataSignManager @Inject constructor(
    private val walletConnectSignValidator: WalletConnectSignValidator,
    private val signHelper: WalletConnectArbitraryDataSignHelper,
    private val accountDetailUseCase: AccountDetailUseCase
) : LifecycleScopedCoroutineOwner() {

    val signResultLiveData: LiveData<WalletConnectSignResult>
        get() = _signResultLiveData
    private val _signResultLiveData = MutableLiveData<WalletConnectSignResult>()

    private var arbitraryData: WalletConnectArbitraryDataRequest? = null

    private val signHelperListener = object : ListQueuingHelper.Listener<WalletConnectArbitraryData, ByteArray> {
        override fun onAllItemsDequeued(signedTransactions: List<ByteArray?>) {
            arbitraryData?.run {
                _signResultLiveData.postValue(Success(session.sessionIdentifier, requestId, signedTransactions))
            }
        }

        override fun onNextItemToBeDequeued(
            arbitraryData: WalletConnectArbitraryData,
            currentItemIndex: Int,
            totalItemCount: Int
        ) {
            val accountType = getSignerAccountType(arbitraryData.signerAccount?.address)
            if (accountType == null) {
                signHelper.cacheDequeuedItem(null)
            } else {
                arbitraryData.signArbitraryData(
                    accountDetail = accountType
                )
            }
        }
    }

    fun setup(lifecycle: Lifecycle) {
        assignToLifecycle(lifecycle)
        signHelper.initListener(signHelperListener)
    }

    fun signArbitraryData(arbitraryData: WalletConnectArbitraryDataRequest) {
        postResult(WalletConnectSignResult.Loading)
        this.arbitraryData = arbitraryData
        with(arbitraryData) {
            when (val result = walletConnectSignValidator.canArbitraryDataBeSigned(this)) {
                is WalletConnectSignResult.CanBeSigned -> {
                    signHelper.initItemsToBeEnqueued(arbitraryDataList)
                }

                is WalletConnectSignResult.Error -> postResult(result)
                else -> {
                    sendErrorLog("Unhandled else case in WalletConnectSignManager.signTransaction")
                }
            }
        }
    }

    private fun WalletConnectArbitraryData.signArbitraryData(
        accountDetail: Account.Detail
    ) {
        val secretKey = when (accountDetail) {
            is Standard -> accountDetail.secretKey
            is Rekeyed -> accountDetail.secretKey
            is RekeyedAuth -> accountDetail.secretKey
            else -> {
                null
            }
        }

        if (secretKey != null) {
            signHelper.cacheDequeuedItem(decodedTransaction?.signArbitraryData(secretKey))
        } else {
            signHelper.cacheDequeuedItem(null)
        }
    }

    private fun getSignerAccountType(signerAccountAddress: String?): Account.Detail? {
        if (signerAccountAddress.isNullOrBlank()) return null
        return accountDetailUseCase.getCachedAccountDetail(signerAccountAddress)?.data?.account?.detail
    }

    private fun postResult(walletConnectSignResult: WalletConnectSignResult) {
        _signResultLiveData.postValue(walletConnectSignResult)
    }

    override fun stopAllResources() {
        signHelper.clearCachedData()
        arbitraryData = null
    }

    fun manualStopAllResources() {
        this.stopAllResources()
        currentScope.coroutineContext.cancelChildren()
    }
}
