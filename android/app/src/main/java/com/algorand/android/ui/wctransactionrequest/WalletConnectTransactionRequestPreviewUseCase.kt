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

package com.algorand.android.ui.wctransactionrequest

import com.algorand.android.models.Account.Type.LEDGER
import com.algorand.android.models.Account.Type.REKEYED
import com.algorand.android.models.Account.Type.REKEYED_AUTH
import com.algorand.android.models.Account.Type.STANDARD
import com.algorand.android.models.Account.Type.WATCH
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.usecase.AccountDetailUseCase
import javax.inject.Inject

class WalletConnectTransactionRequestPreviewUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase
) {

    fun isBluetoothNeededToSignTxns(transaction: WalletConnectTransaction): Boolean {
        return transaction.transactionList.flatten().any {
            val accountDetail = it.fromAccount?.type ?: return false
            when (accountDetail) {
                LEDGER, REKEYED_AUTH -> true
                // [Watch] account is not realistic but would be nice to see it here
                STANDARD, WATCH -> false
                REKEYED -> isAuthALedgerAccount(it.fromAccount?.address)
            }
        }
    }

    private fun isAuthALedgerAccount(accountAddress: String?): Boolean {
        val authAccount = accountDetailUseCase.getAuthAccount(accountAddress)?.data?.account ?: return false
        return when (authAccount.type) {
            LEDGER -> true
            STANDARD, REKEYED, REKEYED_AUTH, WATCH, null -> false
        }
    }
}
