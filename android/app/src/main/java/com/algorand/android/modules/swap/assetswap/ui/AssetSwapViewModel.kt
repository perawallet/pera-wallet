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
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapType
import com.algorand.android.modules.swap.assetswap.ui.model.AssetSwapPreview
import com.algorand.android.modules.swap.assetswap.ui.usecase.AssetSwapPreviewUseCase
import com.algorand.android.modules.tracking.swap.assetswap.AssetSwapSwapButtonClickEventTracker
import com.algorand.android.utils.Event
import com.algorand.android.utils.getOrElse
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.flatMapLatest
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
    private val amountInputFlow = MutableStateFlow<String?>(null)
    private var percentageCacheEvent: Event<Float>? = null

    // Swap Type won't be changed for Swap v1. It will be enabled if we need in the future.
    // To enable it, simply remove comments at; Line:67, Line:72, Line:81 and make it `var`
    private val swapType = SwapType.FIXED_INPUT

    private val _assetSwapPreviewFlow = MutableStateFlow<AssetSwapPreview>(
        assetSwapPreviewUseCase.getAssetSwapPreviewInitializationState(
            accountAddress = accountAddress,
            fromAssetId = fromAssetId,
            toAssetId = toAssetId
        )
    )

    val assetSwapPreviewFlow: StateFlow<AssetSwapPreview>
        get() = _assetSwapPreviewFlow

    init {
        initAmountInputFlow()
    }

    fun onFromAmountChanged(rawAmount: String) {
        // swapType = SwapType.FIXED_INPUT
        amountInputFlow.value = rawAmount
    }

    fun onToAmountChanged(rawAmount: String) {
        // swapType = SwapType.FIXED_OUTPUT
        amountInputFlow.value = rawAmount
    }

    fun onSwitchAssetsClick() {
        toAssetId?.let { safeToAssetId ->
            viewModelScope.launch {
                toAssetId = fromAssetId
                fromAssetId = safeToAssetId
                // swapType = if (swapType == SwapType.FIXED_OUTPUT) SwapType.FIXED_INPUT else SwapType.FIXED_OUTPUT
                val currentAmountInput = amountInputFlow.value
                if (currentAmountInput.isNullOrBlank()) {
                    assetSwapPreviewUseCase.getAssetsSwitchedUpdatedPreview(
                        fromAssetId = fromAssetId,
                        toAssetId = toAssetId!!,
                        amount = currentAmountInput,
                        accountAddress = accountAddress,
                        swapType = swapType,
                        previousState = _assetSwapPreviewFlow.value
                    ).collectLatest { newPreview ->
                        _assetSwapPreviewFlow.value = newPreview
                    }
                } else {
                    amountInputFlow.value = _assetSwapPreviewFlow.value.toSelectedAssetAmountDetail?.amount
                }
            }
        }
    }

    fun onMaxButtonClick() {
        onBalancePercentageSelected(MAX_BALANCE_PERCENTAGE)
    }

    fun onBalancePercentageSelected(percentage: Float) {
        if (toAssetId == null) return
        viewModelScope.launch {
            with(assetSwapPreviewUseCase) {
                getBalanceForSelectedPercentage(
                    previousAmount = amountInputFlow.value.orEmpty(),
                    fromAssetId = fromAssetId,
                    percentage = percentage,
                    accountAddress = accountAddress,
                    onLoadingChange = {
                        _assetSwapPreviewFlow.value = _assetSwapPreviewFlow.value.copy(isLoadingVisible = it)
                    },
                    onSuccess = {
                        with(_assetSwapPreviewFlow) {
                            value = getPercentageCalculationSuccessPreview(percentage, value)
                        }
                        percentageCacheEvent = Event(percentage)
                        onFromAmountChanged(it)
                    },
                    onFailure = {
                        with(_assetSwapPreviewFlow) {
                            value = getPercentageCalculationFailedPreview(it, value)
                        }
                    }
                )
            }
        }
    }

    fun onSwapButtonClick() {
        viewModelScope.launch {
            assetSwapButtonClickEventTracker.logSwapButtonClickEvent()
        }
        with(_assetSwapPreviewFlow) {
            value = assetSwapPreviewUseCase.getSwapButtonClickUpdatedPreview(value)
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
        viewModelScope.launch(Dispatchers.IO) {
            assetSwapPreviewUseCase.getFromAssetUpdatedPreview(
                fromAssetId = fromAssetId,
                toAssetId = currentToAssetId,
                amount = amountInputFlow.value,
                accountAddress = accountAddress,
                swapType = swapType,
                previousState = _assetSwapPreviewFlow.value
            ).collectLatest { newPreview ->
                _assetSwapPreviewFlow.value = newPreview
            }
        }
    }

    fun updateToAssetId(assetId: Long) {
        toAssetId = assetId
        viewModelScope.launch(Dispatchers.IO) {
            assetSwapPreviewUseCase.getToAssetUpdatedPreview(
                fromAssetId = fromAssetId,
                toAssetId = assetId,
                amount = amountInputFlow.value,
                fromAssetDecimal = _assetSwapPreviewFlow.value.fromSelectedAssetDetail.assetDecimal,
                accountAddress = accountAddress,
                swapType = swapType,
                previousState = _assetSwapPreviewFlow.value
            ).collectLatest { newPreview ->
                _assetSwapPreviewFlow.value = newPreview
            }
        }
    }

    private fun initAmountInputFlow() {
        viewModelScope.launch(Dispatchers.IO) {
            amountInputFlow
                .flatMapLatest { amount ->
                    assetSwapPreviewUseCase.getAmountUpdatedPreview(
                        fromAssetId = fromAssetId,
                        toAssetId = toAssetId,
                        amount = amount,
                        accountAddress = accountAddress,
                        swapType = swapType,
                        percentage = percentageCacheEvent?.consume(),
                        previousState = _assetSwapPreviewFlow.value
                    )
                }
                .debounce(AMOUNT_UPDATE_DEBOUNCE_TIMEOUT)
                .collectLatest { newAssetSwapPreview ->
                    _assetSwapPreviewFlow.value = newAssetSwapPreview
                }
        }
    }

    companion object {
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
        private const val FROM_ASSET_ID_KEY = "fromAssetId"
        private const val TO_ASSET_ID_KEY = "toAssetId"
        private const val DEFAULT_ASSET_ID_ARG = -1L
        private const val AMOUNT_UPDATE_DEBOUNCE_TIMEOUT = 400L
        private const val MAX_BALANCE_PERCENTAGE = 100f
    }
}
