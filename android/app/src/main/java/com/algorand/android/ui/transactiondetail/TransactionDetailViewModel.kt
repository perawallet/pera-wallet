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

package com.algorand.android.ui.transactiondetail

import android.content.SharedPreferences
import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.preference.isTransactionDetailCopyTutorialShown
import com.algorand.android.utils.preference.setTransactionDetailCopyShown

class TransactionDetailViewModel @ViewModelInject constructor(
    private val algodInterceptor: AlgodInterceptor,
    private val sharedPref: SharedPreferences,
    private val accountCacheManager: AccountCacheManager,
    @Assisted savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val transaction = savedStateHandle.get<BaseTransactionItem.TransactionItem>(TRANSACTION_ITEM_KEY)

    fun getTransaction(): BaseTransactionItem.TransactionItem? {
        return transaction
    }

    fun getTxnAssetInformation(): AssetInformation? {
        return transaction?.assetId?.let {
            accountCacheManager.getAssetInformation(transaction.accountPublicKey, it)
        }
    }

    fun getNetworkSlug(): String? {
        return algodInterceptor.currentActiveNode?.networkSlug
    }

    fun getAccountCacheData(address: String): AccountCacheData? {
        return accountCacheManager.getCacheData(address)
    }

    fun isCopyTutorialNeeded(): Boolean {
        return sharedPref.isTransactionDetailCopyTutorialShown().not()
    }

    fun toggleCopyTutorialShownFlag() {
        sharedPref.setTransactionDetailCopyShown()
    }

    companion object {
        private const val TRANSACTION_ITEM_KEY = "transactionItem"
    }
}
