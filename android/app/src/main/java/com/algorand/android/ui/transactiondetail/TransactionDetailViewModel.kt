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

package com.algorand.android.ui.transactiondetail

import android.content.SharedPreferences
import androidx.hilt.lifecycle.ViewModelInject
import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseViewModel
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.utils.preference.isTransactionDetailCopyTutorialShown
import com.algorand.android.utils.preference.setTransactionDetailCopyShown

class TransactionDetailViewModel @ViewModelInject constructor(
    private val algodInterceptor: AlgodInterceptor,
    private val accountManager: AccountManager,
    private val sharedPref: SharedPreferences
) : BaseViewModel() {

    fun getNetworkSlug(): String? {
        return algodInterceptor.currentActiveNode?.networkSlug
    }

    fun getAccountName(address: String): String {
        return accountManager.getAccount(address)?.name.orEmpty()
    }

    fun isCopyTutorialNeeded(): Boolean {
        return sharedPref.isTransactionDetailCopyTutorialShown().not()
    }

    fun toggleCopyTutorialShownFlag() {
        sharedPref.setTransactionDetailCopyShown()
    }
}
