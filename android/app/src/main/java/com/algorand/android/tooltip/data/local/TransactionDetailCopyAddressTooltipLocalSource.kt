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

package com.algorand.android.tooltip.data.local

import android.content.SharedPreferences
import com.algorand.android.sharedpref.SharedPrefLocalSource
import javax.inject.Inject

class TransactionDetailCopyAddressTooltipLocalSource @Inject constructor(
    sharedPreferences: SharedPreferences
) : SharedPrefLocalSource<Boolean>(sharedPreferences) {

    override val key: String
        get() = TRANSACTION_DETAIL_COPY_TUTORIAL_SHOWN_KEY

    override fun getData(defaultValue: Boolean): Boolean {
        return sharedPref.getBoolean(key, defaultValue)
    }

    override fun getDataOrNull(): Boolean? {
        return sharedPref.getBoolean(key, defaultTransactionDetailTooltipPreference).takeIf {
            sharedPref.contains(key)
        }
    }

    override fun saveData(data: Boolean) {
        saveData { it.putBoolean(key, data) }
    }

    companion object {
        private const val TRANSACTION_DETAIL_COPY_TUTORIAL_SHOWN_KEY = "transaction_detail_copy_shown_key"
        const val defaultTransactionDetailTooltipPreference = true
    }
}
