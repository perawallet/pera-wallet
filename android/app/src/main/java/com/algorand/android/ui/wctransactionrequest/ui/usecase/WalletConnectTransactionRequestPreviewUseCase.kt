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

package com.algorand.android.ui.wctransactionrequest.ui.usecase

import com.algorand.android.models.Account
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.modules.walletconnect.domain.WalletConnectManager
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.ui.wctransactionrequest.ui.mapper.WalletConnectTransactionRequestPreviewMapper
import com.algorand.android.ui.wctransactionrequest.ui.model.WalletConnectTransactionRequestPreview
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.Event
import javax.inject.Inject

class WalletConnectTransactionRequestPreviewUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val walletConnectTransactionRequestPreviewMapper: WalletConnectTransactionRequestPreviewMapper,
    private val walletConnectManager: WalletConnectManager
) {

    fun isBluetoothNeededToSignTxns(transaction: WalletConnectTransaction): Boolean {
        return transaction.transactionList.flatten().any {
            val accountDetail = it.fromAccount?.type ?: return false
            when (accountDetail) {
                Account.Type.LEDGER, Account.Type.REKEYED_AUTH -> true
                // [Watch] account is not realistic but would be nice to see it here
                Account.Type.STANDARD, Account.Type.WATCH -> false
                Account.Type.REKEYED -> isAuthALedgerAccount(it.fromAccount?.address)
            }
        }
    }

    private fun isAuthALedgerAccount(accountAddress: String?): Boolean {
        val authAccount = accountDetailUseCase.getAuthAccount(accountAddress)?.data?.account ?: return false
        return when (authAccount.type) {
            Account.Type.LEDGER -> true
            Account.Type.STANDARD, Account.Type.REKEYED, Account.Type.REKEYED_AUTH, Account.Type.WATCH, null -> false
        }
    }

    fun getInitialWalletConnectTransactionRequestPreview(): WalletConnectTransactionRequestPreview {
        return walletConnectTransactionRequestPreviewMapper.mapToWalletConnectTransactionRequestPreview()
    }

    suspend fun updatePreviewWithLaunchBackBrowserNavigation(
        shouldSkipConfirmation: Boolean,
        preview: WalletConnectTransactionRequestPreview,
        walletConnectSession: WalletConnectSession?
    ): WalletConnectTransactionRequestPreview {
        if (walletConnectSession == null) {
            return preview.copy(navBackEvent = Event(Unit))
        }
//        extendSessionExpirationDateIfCan(walletConnectSession.sessionIdentifier)
        if (shouldSkipConfirmation) {
            return preview.copy(navBackEvent = Event(Unit))
        }
        return preview.copy(navToLaunchBackNavigationEvent = Event(walletConnectSession.sessionIdentifier))
    }

    private suspend fun extendSessionExpirationDateIfCan(sessionIdentifier: WalletConnectSessionIdentifier) {
        val isSessionExtendable = walletConnectManager.isSessionExtendable(sessionIdentifier)
        if (isSessionExtendable == true) {
            walletConnectManager.extendSessionExpirationDate(sessionIdentifier)
        }
    }
}
