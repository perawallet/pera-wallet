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

package com.algorand.android.modules.assets.profile.detail.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.modules.assets.profile.detail.ui.model.AssetDetailPreview
import com.algorand.android.modules.assets.profile.detail.ui.usecase.AssetDetailPreviewUseCase
import com.algorand.android.modules.tracking.swap.assetdetail.AssetDetailAlgoSwapClickEventTracker
import com.algorand.android.usecase.AccountDeletionUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class AssetDetailViewModel @Inject constructor(
    private val assetDetailPreviewUseCase: AssetDetailPreviewUseCase,
    private val accountDeletionUseCase: AccountDeletionUseCase,
    private val algoSwapClickEventTracker: AssetDetailAlgoSwapClickEventTracker,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    val assetId = savedStateHandle.getOrThrow<Long>(ASSET_ID_KEY)
    val accountAddress = savedStateHandle.getOrThrow<String>(ACCOUNT_ADDRESS_KEY)
    private val isQuickActionButtonsVisible = savedStateHandle.getOrThrow<Boolean>(IS_QUICK_ACTION_BUTTONS_VISIBLE_KEY)

    private val _assetDetailPreviewFlow = MutableStateFlow<AssetDetailPreview?>(null)
    val assetDetailPreviewFlow: StateFlow<AssetDetailPreview?> get() = _assetDetailPreviewFlow

    init {
        initAssetDetailPreview()
    }

    fun onSwapButtonClick() {
        val currentPreview = _assetDetailPreviewFlow.value ?: return
        viewModelScope.launch {
            if (assetId == ALGO_ID) algoSwapClickEventTracker.logAlgoSwapClickEvent()
            assetDetailPreviewUseCase.updatePreviewForNavigatingSwap(
                currentPreview = currentPreview,
                accountAddress = accountAddress
            ).collect {
                _assetDetailPreviewFlow.emit(it)
            }
        }
    }

    fun removeAccount() {
        viewModelScope.launch(Dispatchers.IO) {
            accountDeletionUseCase.removeAccount(accountAddress)
        }
    }

    fun onMarketClick() {
        with(_assetDetailPreviewFlow) {
            val currentPreview = value ?: return@with
            value = assetDetailPreviewUseCase.updatePreviewForDiscoverMarketEvent(currentPreview)
        }
    }

    private fun initAssetDetailPreview() {
        viewModelScope.launch {
            assetDetailPreviewUseCase.initAssetDetailPreview(
                accountAddress = accountAddress,
                assetId = assetId,
                isQuickActionButtonsVisible = isQuickActionButtonsVisible
            ).collect {
                _assetDetailPreviewFlow.emit(it)
            }
        }
    }

    companion object {
        const val ASSET_ID_KEY = "assetId"
        const val ACCOUNT_ADDRESS_KEY = "accountAddress"
        const val IS_QUICK_ACTION_BUTTONS_VISIBLE_KEY = "isQuickActionButtonsVisible"
    }
}
