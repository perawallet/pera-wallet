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

package com.algorand.android.modules.asb.mnemonics.data.local

import android.content.SharedPreferences
import com.algorand.android.sharedpref.SharedPrefLocalSource
import com.algorand.android.utils.decryptString
import com.algorand.android.utils.encryptString
import com.google.crypto.tink.Aead
import javax.inject.Inject

class AsbMnemonicsLocalSource @Inject constructor(
    private val aead: Aead,
    sharedPreferences: SharedPreferences,
) : SharedPrefLocalSource<String?>(sharedPreferences) {

    override val key: String
        get() = ASB_MNEMONICS_KEY

    override fun getData(defaultValue: String?): String? {
        return aead.decryptString(sharedPref.getString(key, defaultValue))
    }

    override fun getDataOrNull(): String? {
        return aead.decryptString(sharedPref.getString(key, null))
    }

    override fun saveData(data: String?) {
        saveData { it.putString(key, aead.encryptString(data)) }
    }

    companion object {
        private const val ASB_MNEMONICS_KEY = "asb_mnemonics_key"
    }
}
