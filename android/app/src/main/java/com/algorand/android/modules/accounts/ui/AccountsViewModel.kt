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

package com.algorand.android.modules.accounts.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.accounts.domain.model.AccountPreview
import com.algorand.android.modules.accounts.domain.usecase.AccountsPreviewUseCase
import com.algorand.android.modules.tracking.accounts.AccountsEventTracker
import com.algorand.android.usecase.IsAccountLimitExceedUseCase
import com.algorand.android.utils.coremanager.ParityManager
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class AccountsViewModel @Inject constructor(
    private val accountsPreviewUseCase: AccountsPreviewUseCase,
    private val accountsEventTracker: AccountsEventTracker,
    private val parityManager: ParityManager,
    private val isAccountLimitExceedUseCase: IsAccountLimitExceedUseCase
) : BaseViewModel() {

    private val _accountPreviewFlow = MutableStateFlow<AccountPreview?>(null)
    val accountPreviewFlow: Flow<AccountPreview?>
        get() = _accountPreviewFlow

    init {
        initializeAccountPreviewFlow()
    }

    fun refreshCachedAlgoPrice() {
        viewModelScope.launch {
            parityManager.refreshSelectedCurrencyDetailCache()
        }
    }

    fun onCloseBannerClick(bannerId: Long) {
        viewModelScope.launch {
            accountsPreviewUseCase.onCloseBannerClick(bannerId)
        }
    }

    private fun initializeAccountPreviewFlow() {
        viewModelScope.launchIO {
            val initialAccountPreview = accountsPreviewUseCase.getInitialAccountPreview()
            _accountPreviewFlow.emit(initialAccountPreview)
            accountsPreviewUseCase.getAccountsPreview(initialAccountPreview).collectLatest {
                _accountPreviewFlow.emit(it)
            }
        }
    }

    fun logQrScanTapEvent() {
        viewModelScope.launch {
            accountsEventTracker.logQrScanTapEvent()
        }
    }

    fun logAddAccountTapEvent() {
        viewModelScope.launch {
            accountsEventTracker.logAddAccountTapEvent()
        }
    }

    fun logAccountsFragmentAlgoBuyTapEvent() {
        viewModelScope.launch {
            accountsEventTracker.logAccountsFragmentAlgoBuyTapEvent()
        }
    }

    fun onBannerActionButtonClick(isGovernance: Boolean) {
        if (isGovernance) {
            viewModelScope.launch {
                accountsEventTracker.logVisitGovernanceEvent()
            }
        }
    }

    fun isAccountLimitExceed(): Boolean {
        return isAccountLimitExceedUseCase.isAccountLimitExceed()
    }

    fun dismissTutorial(tutorialId: Int) {
        viewModelScope.launch {
            accountsPreviewUseCase.dismissTutorial(tutorialId)
        }
    }

    fun onSwapClick() {
        viewModelScope.launch {
            accountsEventTracker.logSwapClickEvent()
            updatePreviewForSwapNavigation()
        }
    }

    fun onSwapClickFromTutorialDialog() {
        viewModelScope.launch {
            accountsEventTracker.logSwapTutorialTrySwapClickEvent()
            updatePreviewForSwapNavigation()
        }
    }

    fun onSwapLaterClick() {
        viewModelScope.launch {
            accountsEventTracker.logSwapLaterClickEvent()
        }
    }

    fun onGiftCardsClickFromTutorialDialog() {
        viewModelScope.launch {
            // TODO add logging?
            updatePreviewForGiftCardsNavigation()
        }
    }

    fun onGiftCardsLaterClick() {
        // TODO add logging?
    }

    private suspend fun updatePreviewForSwapNavigation() {
        with(_accountPreviewFlow) {
            val newState = accountsPreviewUseCase.getSwapNavigationUpdatedPreview(value ?: return@with)
            emit(newState)
        }
    }

    private suspend fun updatePreviewForGiftCardsNavigation() {
        with(_accountPreviewFlow) {
            val newState = accountsPreviewUseCase.getGiftCardsNavigationUpdatedPreview(value ?: return@with)
            emit(newState)
        }
    }
}
