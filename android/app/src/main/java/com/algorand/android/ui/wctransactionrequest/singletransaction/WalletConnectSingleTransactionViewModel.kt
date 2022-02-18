/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.wctransactionrequest.singletransaction

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.ViewModel
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WalletConnectTransactionAmount
import com.algorand.android.models.WalletConnectTransactionShortDetail
import com.algorand.android.models.decider.WalletConnectSingleTransactionUiDecider

class WalletConnectSingleTransactionViewModel @ViewModelInject constructor(
    private val walletConnectSingleTransactionUiDecider: WalletConnectSingleTransactionUiDecider
) : ViewModel() {

    fun buildToolbarTitleRes(txn: BaseWalletConnectTransaction): Int {
        return walletConnectSingleTransactionUiDecider.buildToolbarTitleRes(txn)
    }

    fun buildTransactionAmount(txn: BaseWalletConnectTransaction): WalletConnectTransactionAmount {
        return walletConnectSingleTransactionUiDecider.buildTransactionAmount(txn)
    }

    fun buildTransactionShortDetail(txn: BaseWalletConnectTransaction): WalletConnectTransactionShortDetail {
        return walletConnectSingleTransactionUiDecider.buildTransactionShortDetail(txn)
    }
}
