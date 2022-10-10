package com.algorand.android.ui.accounts

import javax.inject.Inject
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.tracking.accounts.AccountsEventTracker
import dagger.hilt.android.lifecycle.HiltViewModel
import com.algorand.android.usecase.IsAccountLimitExceedUseCase
import kotlinx.coroutines.launch

@HiltViewModel
class AccountsQrScannerViewModel @Inject constructor(
    private val accountsEventTracker: AccountsEventTracker,
    private val isAccountLimitExceedUseCase: IsAccountLimitExceedUseCase
) : BaseViewModel() {

    fun logAccountsQrConnectEvent() {
        viewModelScope.launch {
            accountsEventTracker.logAccountsQrConnectEvent()
        }
    }

    fun isAccountLimitExceed(): Boolean {
        return isAccountLimitExceedUseCase.isAccountLimitExceed()
    }
}
