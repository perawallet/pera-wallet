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

package com.algorand.android.ui.register.ledger.verify

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.usecase.AccountAdditionUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class VerifyLedgerAddressViewModel @Inject constructor(
    private val verifyLedgerAddressQueueManager: VerifyLedgerAddressQueueManager,
    private val accountAdditionUseCase: AccountAdditionUseCase
) : BaseViewModel() {

    val currentLedgerAddressesListLiveData = MutableLiveData<List<VerifyLedgerAddressListItem>>()

    val awaitingLedgerAccountLiveData = MutableLiveData<Account?>()

    val awaitingLedgerAccount
        get() = awaitingLedgerAccountLiveData.value

    val isVerifyOperationsDoneLiveData = MutableLiveData<Event<Boolean>?>()

    private val listLock = Any()

    private val verifyLedgerAddressQueueManagerListener = object : VerifyLedgerAddressQueueManager.Listener {
        override fun onNextQueueItem(ledgerDetail: Account) {
            awaitingLedgerAccountLiveData.value = ledgerDetail
            changeCurrentOperatedAddressStatus(VerifiableLedgerAddressItemStatus.AWAITING_VERIFICATION)
        }

        override fun onQueueCompleted() {
            awaitingLedgerAccountLiveData.postValue(null)
            isVerifyOperationsDoneLiveData.postValue(Event(true))
        }
    }

    init {
        verifyLedgerAddressQueueManager.setListener(verifyLedgerAddressQueueManagerListener)
    }

    fun createListAuthLedgerAccounts(authLedgerAccounts: List<Account>) {
        val verifiableLedgerAddress: List<VerifyLedgerAddressListItem> = authLedgerAccounts.map { ledgerAccount ->
            VerifyLedgerAddressListItem.VerifiableLedgerAddressItem(ledgerAccount.address)
        }
        verifiableLedgerAddress.toMutableList().add(0, VerifyLedgerAddressListItem.VerifyLedgerHeaderItem)
        currentLedgerAddressesListLiveData.value = verifiableLedgerAddress
        verifyLedgerAddressQueueManager.fillQueue(authLedgerAccounts)
    }

    fun onCurrentOperationDone(isVerified: Boolean) {
        changeCurrentOperatedAddressStatus(
            if (isVerified) {
                VerifiableLedgerAddressItemStatus.APPROVED
            } else {
                VerifiableLedgerAddressItemStatus.REJECTED
            }
        )
        moveToNextVerification()
    }

    private fun moveToNextVerification() {
        verifyLedgerAddressQueueManager.moveQueue()
    }

    fun changeCurrentOperatedAddressStatus(newStatus: VerifiableLedgerAddressItemStatus) {
        synchronized(listLock) {
            val currentList = currentLedgerAddressesListLiveData.value
            val currentOperatedAddress = awaitingLedgerAccount?.address
            if (currentList != null && currentOperatedAddress != null) {
                val newList = mutableListOf<VerifyLedgerAddressListItem>().apply {
                    add(VerifyLedgerAddressListItem.VerifyLedgerHeaderItem)
                }
                currentList
                    .filterIsInstance<VerifyLedgerAddressListItem.VerifiableLedgerAddressItem>()
                    .forEach {
                        val changedStatus = if (it.address == currentOperatedAddress) newStatus else it.status
                        val copyItem = it.copy(status = changedStatus)
                        newList.add(copyItem)
                    }
                currentLedgerAddressesListLiveData.value = newList
            }
        }
    }

    private fun getAllApprovedAuths(): List<VerifyLedgerAddressListItem.VerifiableLedgerAddressItem> {
        return currentLedgerAddressesListLiveData.value
            ?.filterIsInstance<VerifyLedgerAddressListItem.VerifiableLedgerAddressItem>()
            ?.filter { it.status == VerifiableLedgerAddressItemStatus.APPROVED }
            .orEmpty()
    }

    fun getSelectedVerifiedAccounts(allSelectedAccounts: List<Account>): List<Account> {
        val approvedLedgerAuths = getAllApprovedAuths()
        if (approvedLedgerAuths.isEmpty()) {
            return emptyList()
        }
        val accountList = mutableListOf<Account>()
        for (selectedAccount in allSelectedAccounts) {
            when (selectedAccount.detail) {
                is Account.Detail.RekeyedAuth -> {
                    if (approvedLedgerAuths.any { selectedAccount.detail.rekeyedAuthDetail.containsKey(it.address) })
                        accountList.add(selectedAccount)
                }
                else -> {
                    if (approvedLedgerAuths.any { selectedAccount.address == it.address })
                        accountList.add(selectedAccount)
                }
            }
        }
        return accountList
    }

    fun addNewAccount(account: Account, creationType: CreationType?) {
        viewModelScope.launchIO {
            accountAdditionUseCase.addNewAccount(account, creationType)
        }
    }
}
