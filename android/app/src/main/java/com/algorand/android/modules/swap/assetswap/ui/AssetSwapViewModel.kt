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

package com.algorand.android.modules.swap.assetswap.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.modules.swap.assetswap.ui.model.AssetSwapPreview
import com.algorand.android.modules.swap.assetswap.ui.usecase.AssetSwapPreviewUseCase
import com.algorand.android.modules.tracking.swap.assetswap.AssetSwapSwapButtonClickEventTracker
import com.algorand.android.utils.Event
import com.algorand.android.utils.getOrElse
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class AssetSwapViewModel @Inject constructor(
    private val assetSwapPreviewUseCase: AssetSwapPreviewUseCase,
    private val assetSwapButtonClickEventTracker: AssetSwapSwapButtonClickEventTracker,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    val accountAddress = savedStateHandle.getOrThrow<String>(ACCOUNT_ADDRESS_KEY)

    var fromAssetId: Long = savedStateHandle.getOrElse(FROM_ASSET_ID_KEY, DEFAULT_ASSET_ID_ARG)
        .takeIf { it != DEFAULT_ASSET_ID_ARG }
        ?: ALGO_ID
        private set
    private var toAssetId: Long? = savedStateHandle.getOrElse(TO_ASSET_ID_KEY, DEFAULT_ASSET_ID_ARG)
        .takeIf { it != DEFAULT_ASSET_ID_ARG }
    private var percentageCacheEvent: Event<Float>? = null
    private var previewUpdateJob: Job? = null

    private val _assetSwapPreviewFlow = MutableStateFlow(
        assetSwapPreviewUseCase.getAssetSwapPreviewInitializationState(
            accountAddress = accountAddress,
            fromAssetId = fromAssetId,
            toAssetId = toAssetId
        )
    )

    private val _isAccountCachedResultFlow = MutableStateFlow<Boolean>(
        assetSwapPreviewUseCase.isAccountCachedSuccessfully(accountAddress)
    )
    val isAccountCachedResultFlow: StateFlow<Boolean>
        get() = _isAccountCachedResultFlow

    val assetSwapPreviewFlow: StateFlow<AssetSwapPreview?>
        get() = _assetSwapPreviewFlow

    private val latestFromAmount: String?
        get() = _assetSwapPreviewFlow.value?.fromSelectedAssetAmountDetail?.amount

    fun onFromAmountChanged(rawAmount: String) {
        updateSwapQuote(amount = rawAmount, shouldInterruptActiveJob = true)
    }

    fun onSwitchAssetsClick() {
        toAssetId?.let { safeToAssetId ->
            withPreviewUpdateJob(shouldInterruptActiveJob = true) {
                viewModelScope.launch {
                    toAssetId = fromAssetId
                    fromAssetId = safeToAssetId
                    assetSwapPreviewUseCase.getAssetsSwitchedUpdatedPreview(
                        fromAssetId = fromAssetId,
                        toAssetId = toAssetId!!,
                        accountAddress = accountAddress,
                        previousState = _assetSwapPreviewFlow.value ?: return@launch
                    ).collectLatest { newPreview ->
                        _assetSwapPreviewFlow.value = newPreview
                    }
                }
            }
        }
    }

    fun onMaxButtonClick() {
        onBalancePercentageSelected(MAX_BALANCE_PERCENTAGE)
    }

    fun onBalancePercentageSelected(percentage: Float) {
        if (toAssetId == null) return
        withPreviewUpdateJob(shouldInterruptActiveJob = true) {
            viewModelScope.launch {
                with(assetSwapPreviewUseCase) {
                    getBalanceForSelectedPercentage(
                        previousAmount = latestFromAmount.orEmpty(),
                        fromAssetId = fromAssetId,
                        percentage = percentage,
                        accountAddress = accountAddress,
                        onLoadingChange = {
                            _assetSwapPreviewFlow.value = _assetSwapPreviewFlow.value?.copy(isLoadingVisible = it)
                        },
                        onSuccess = {
                            _assetSwapPreviewFlow.value = getPercentageCalculationSuccessPreview(
                                percentage = percentage,
                                previousState = _assetSwapPreviewFlow.value ?: return@getBalanceForSelectedPercentage
                            )
                            percentageCacheEvent = Event(percentage)
                            onFromAmountChanged(it)
                        },
                        onFailure = {
                            _assetSwapPreviewFlow.value = getPercentageCalculationFailedPreview(
                                errorEvent = it,
                                previousState = _assetSwapPreviewFlow.value ?: return@getBalanceForSelectedPercentage
                            )
                        }
                    )
                }
            }
        }
    }

    fun onSwapButtonClick() {
        viewModelScope.launch {
            assetSwapButtonClickEventTracker.logSwapButtonClickEvent()
        }
        with(_assetSwapPreviewFlow) {
            value = assetSwapPreviewUseCase.getSwapButtonClickUpdatedPreview(value ?: return@with)
        }
    }

    fun updateFromAssetId(assetId: Long) {
        fromAssetId = assetId
        // We need previously selected `to asset id` while preparing the preview
        // But also we need to clear cached `to asset id` value if fromAssetId & toAssetId are equal
        // That's why we assign it `currentToAssetId` before clearing the global variable
        val currentToAssetId = toAssetId
        if (fromAssetId == toAssetId) {
            toAssetId = null
        }
        withPreviewUpdateJob(shouldInterruptActiveJob = true) {
            viewModelScope.launch(Dispatchers.IO) {
                assetSwapPreviewUseCase.getFromAssetUpdatedPreview(
                    fromAssetId = fromAssetId,
                    toAssetId = currentToAssetId,
                    amount = latestFromAmount,
                    accountAddress = accountAddress,
                    previousState = _assetSwapPreviewFlow.value ?: return@launch
                ).collectLatest { newPreview ->
                    _assetSwapPreviewFlow.value = newPreview
                }
            }
        }
    }

    fun updateToAssetId(assetId: Long) {
        toAssetId = assetId
        withPreviewUpdateJob(shouldInterruptActiveJob = true) {
            viewModelScope.launch(Dispatchers.IO) {
                val fromAssetDecimal = _assetSwapPreviewFlow.value?.fromSelectedAssetDetail?.assetDecimal
                    ?: return@launch
                assetSwapPreviewUseCase.getToAssetUpdatedPreview(
                    fromAssetId = fromAssetId,
                    toAssetId = assetId,
                    amount = latestFromAmount,
                    fromAssetDecimal = fromAssetDecimal,
                    accountAddress = accountAddress,
                    previousState = _assetSwapPreviewFlow.value ?: return@launch
                ).collectLatest { newPreview ->
                    _assetSwapPreviewFlow.value = newPreview
                }
            }
        }
    }

    fun refreshPreview() {
        updateSwapQuote(latestFromAmount, shouldInterruptActiveJob = false)
    }

    private fun updateSwapQuote(
        amount: String?,
        shouldInterruptActiveJob: Boolean
    ) {
        withPreviewUpdateJob(shouldInterruptActiveJob) {
            viewModelScope.launch {
                delay(AMOUNT_UPDATE_DEBOUNCE_TIMEOUT)
                assetSwapPreviewUseCase.getAmountUpdatedPreview(
                    fromAssetId = fromAssetId,
                    toAssetId = toAssetId,
                    amount = amount,
                    accountAddress = accountAddress,
                    percentage = percentageCacheEvent?.consume(),
                    previousState = _assetSwapPreviewFlow.value
                ).collectLatest { newAssetSwapPreview ->
                    _assetSwapPreviewFlow.value = newAssetSwapPreview
                }
            }
        }
    }

    private fun withPreviewUpdateJob(shouldInterruptActiveJob: Boolean, action: () -> Job?) {
        if (!shouldInterruptActiveJob) return
        if (previewUpdateJob?.isActive == true) {
            previewUpdateJob?.cancel()
        }
        previewUpdateJob = action()
    }

    companion object {
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
        private const val FROM_ASSET_ID_KEY = "fromAssetId"
        private const val DEFAULT_ASSET_ID_ARG = -1L
        private const val TO_ASSET_ID_KEY = "toAssetId"
        private const val AMOUNT_UPDATE_DEBOUNCE_TIMEOUT = 400L
        private const val MAX_BALANCE_PERCENTAGE = 100f
    }
}
