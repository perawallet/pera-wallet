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

package com.algorand.android.ui.send

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.Result
import com.algorand.android.models.SendTransactionResponse
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TrackTransactionRequest
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.network.getAsResourceError
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.utils.Event
import com.algorand.android.utils.MAINNET_NETWORK_SLUG
import com.algorand.android.utils.Resource
import com.algorand.android.utils.analytics.logTransactionEvent
import com.google.firebase.analytics.FirebaseAnalytics
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

class SendActionViewModel @ViewModelInject constructor(
    private val transactionsRepository: TransactionsRepository,
    private val firebaseAnalytics: FirebaseAnalytics,
    private val algodInterceptor: AlgodInterceptor
) : BaseViewModel() {

    private var sendAlgoJob: Job? = null
    val sendAlgoResponseLiveData = MutableLiveData<Event<Resource<SendTransactionResponse>>>()

    fun sendSignedTransaction(signedTransactionDetail: SignedTransactionDetail.Send) {
        if (sendAlgoJob?.isActive == true) {
            return
        }
        sendAlgoResponseLiveData.value = Event(Resource.Loading)

        sendAlgoJob = viewModelScope.launch(Dispatchers.IO) {
            val signedTransactionData = signedTransactionDetail.signedTransactionData
            when (val result = transactionsRepository.sendSignedTransaction(signedTransactionData)) {
                is Result.Success -> {
                    result.data.taxId?.run {
                        transactionsRepository.postTrackTransaction(TrackTransactionRequest(this))
                    }
                    sendTransactionEvent(signedTransactionDetail)
                    sendAlgoResponseLiveData.postValue(Event(Resource.Success(result.data)))
                }
                is Result.Error -> {
                    sendAlgoResponseLiveData.postValue(Event(result.getAsResourceError()))
                }
            }
        }
    }

    private fun sendTransactionEvent(signedTransactionDetail: SignedTransactionDetail.Send) {
        if (algodInterceptor.currentActiveNode?.networkSlug == MAINNET_NETWORK_SLUG) {
            with(signedTransactionDetail) {
                firebaseAnalytics.logTransactionEvent(
                    amount = amount,
                    assetId = assetInformation.assetId,
                    accountType = accountCacheData.account.type ?: Account.Type.STANDARD,
                    isMax = isMax
                )
            }
        }
    }
}
