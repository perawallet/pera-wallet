package com.algorand.android.ui.accounts

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.tracking.accounts.AccountsEventTracker
import kotlinx.coroutines.launch

class AccountsQrScannerViewModel @ViewModelInject constructor(
    private val accountsEventTracker: AccountsEventTracker
) : BaseViewModel() {

    fun logAccountsQrConnectEvent() {
        viewModelScope.launch {
            accountsEventTracker.logAccountsQrConnectEvent()
        }
    }
}
