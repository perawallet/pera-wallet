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

package com.algorand.android.ui.register.ledger.verify

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.utils.Event

class VerifyLedgerAddressViewModel @ViewModelInject constructor(
    private val verifyLedgerAddressQueueManager: VerifyLedgerAddressQueueManager
) : BaseViewModel() {

    val currentLedgerAddressesListLiveData = MutableLiveData<List<VerifiableLedgerAddressItem>>()

    val awaitingLedgerAccountLiveData = MutableLiveData<Account>()

    val awaitingLedgerAccount
        get() = awaitingLedgerAccountLiveData.value

    val isVerifyOperationsDoneLiveData = MutableLiveData<Event<Boolean>>()

    val listLock = Any()

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
        currentLedgerAddressesListLiveData.value = authLedgerAccounts.map { ledgerAccount ->
            VerifiableLedgerAddressItem(ledgerAccount.address)
        }
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
                val newList = mutableListOf<VerifiableLedgerAddressItem>()
                currentList.forEach {
                    val changedStatus = if (it.address == currentOperatedAddress) newStatus else it.status
                    val copyItem = it.copy(status = changedStatus)
                    newList.add(copyItem)
                }
                currentLedgerAddressesListLiveData.value = newList
            }
        }
    }

    private fun getAllApprovedAuths(): List<VerifiableLedgerAddressItem> {
        return currentLedgerAddressesListLiveData.value
            ?.filter { it.status == VerifiableLedgerAddressItemStatus.APPROVED }
            .orEmpty()
    }

    fun getSelectedVerifiedAccounts(allSelectedAccounts: List<Account>): List<Account> {
        val approvedLedgerAuths = getAllApprovedAuths()
        if (approvedLedgerAuths.isEmpty()) {
            return emptyList()
        }

        return mutableListOf<Account>().apply {
            outerloop@ for (selectedAccount in allSelectedAccounts) {
                if (approvedLedgerAuths.any { it.address == selectedAccount.address }) {
                    add(selectedAccount)
                    continue
                }
                if (selectedAccount.detail is Account.Detail.RekeyedAuth) {
                    for (auth in approvedLedgerAuths) {
                        if (selectedAccount.detail.rekeyedAuthDetail.containsKey(auth.address)) {
                            add(selectedAccount)
                            continue@outerloop
                        }
                    }
                }
            }
        }
    }
}
