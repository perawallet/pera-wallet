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

package com.algorand.android.modules.swap.common.data.local

import android.content.SharedPreferences
import com.algorand.android.sharedpref.SharedPrefLocalSource
import javax.inject.Inject

class SwapSlippageToleranceLocalSource @Inject constructor(
    sharedPreferences: SharedPreferences
) : SharedPrefLocalSource<Float>(sharedPreferences) {

    override val key: String = SWAP_SLIPPAGE_TOLERANCE_KEY

    override fun getData(defaultValue: Float): Float {
        return sharedPref.getFloat(key, defaultValue)
    }

    override fun saveData(data: Float) {
        saveData { it.putFloat(key, data) }
    }

    override fun getDataOrNull(): Float? {
        return if (sharedPref.contains(key)) sharedPref.getFloat(key, DEFAULT_SLIPPAGE_TOLERANCE) else null
    }

    companion object {
        private const val SWAP_SLIPPAGE_TOLERANCE_KEY = "swap_slippage_tolerance_key"

        // Default value below shouldn't be used in app. It was added because sharedPref.getFloat doesn't accept null
        private const val DEFAULT_SLIPPAGE_TOLERANCE = -1f
    }
}
