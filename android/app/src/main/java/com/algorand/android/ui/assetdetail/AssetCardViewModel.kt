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

package com.algorand.android.ui.assetdetail

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.AlgoBalanceInformation
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.BaseAlgoRewardWrapper.BlockResult
import com.algorand.android.models.BaseAlgoRewardWrapper.TotalAlgoSupplyResult
import com.algorand.android.models.CurrencyValue
import com.algorand.android.repository.AlgoRewardRepository
import com.algorand.android.repository.PriceRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.AlgoRewardResponseHandler
import com.algorand.android.utils.getAlgoBalanceAsCurrencyValue
import java.math.BigInteger
import java.math.BigInteger.ZERO
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.launch

class AssetCardViewModel @ViewModelInject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val priceRepository: PriceRepository,
    private val algoRewardRepository: AlgoRewardRepository,
    private val rewardResponseHandler: AlgoRewardResponseHandler
) : BaseViewModel() {

    var balanceLiveData: LiveData<BigInteger?>? = null

    var balanceInCurrencyValue: LiveData<String>? = null

    val currencyValueLiveData = MutableLiveData<CurrencyValue>()

    val algoBalanceInformationLiveData = MutableLiveData<AlgoBalanceInformation>()

    private var assetInformationLiveData: LiveData<AssetInformation?>? = null

    private var calculateBlockNumberJob: Job? = null

    fun start(address: String, assetInformation: AssetInformation) {
        if (assetInformation.isAlgorand()) {
            setupAssetInformationLiveData(address)
            getAlgorandCurrencyValue()
            setupBalanceInCurrency()
        } else {
            setupBalanceLiveData(address, assetInformation.assetId)
        }
    }

    fun getPendingRewardsAsMicroAlgo() = algoBalanceInformationLiveData.value?.pendingRewardAsMicroAlgo ?: 0

    fun calculatePendingRewards(blockNumber: Long?) {
        if (blockNumber == null) return
        if (calculateBlockNumberJob?.isActive == true) {
            calculateBlockNumberJob?.cancel()
        }
        calculateBlockNumberJob = launchCalculatePendingRewards(blockNumber)
    }

    private fun launchCalculatePendingRewards(blockNumber: Long): Job {
        return viewModelScope.launch(Dispatchers.IO) {
            with(algoRewardRepository) {
                val deferredRewardResultList = awaitAll(
                    async { TotalAlgoSupplyResult(getTotalAmountOfAlgoInSystem()) },
                    async { BlockResult(getBlockById(blockNumber)) },
                )
                val amountWithoutPendingRewards = assetInformationLiveData?.value?.amountWithoutPendingRewards ?: ZERO
                val earnedRewards = assetInformationLiveData?.value?.pendingRewards ?: 0L
                rewardResponseHandler.handleRewardCallResponseList(
                    amountWithoutPendingRewards,
                    earnedRewards,
                    deferredRewardResultList,
                    onBalanceCalculated = { algoBalanceInformationLiveData.postValue(it) }
                )
            }
        }
    }

    private fun setupBalanceLiveData(address: String, assetId: Long) {
        balanceLiveData = accountCacheManager.getBalanceFlow(address, assetId).asLiveData()
    }

    private fun setupAssetInformationLiveData(address: String) {
        assetInformationLiveData = accountCacheManager.getAssetInformationFlow(address, ALGORAND_ID).asLiveData()
    }

    private fun setupBalanceInCurrency() {
        assetInformationLiveData?.run {
            balanceInCurrencyValue = Transformations.switchMap(this) { assetInfo ->
                Transformations.map(currencyValueLiveData) { currencyValue ->
                    val balance = assetInfo?.amount
                    val valueInCurrency = getAlgoBalanceAsCurrencyValue(balance, currencyValue)
                    currencyValue.getFormattedSignedCurrencyValue(valueInCurrency)
                }
            }
        }
    }

    private fun getAlgorandCurrencyValue() {
        viewModelScope.launch(Dispatchers.IO) {
            priceRepository.getAlgorandCurrencyValue().use(onSuccess = {
                currencyValueLiveData.postValue(it)
            })
        }
    }
}
