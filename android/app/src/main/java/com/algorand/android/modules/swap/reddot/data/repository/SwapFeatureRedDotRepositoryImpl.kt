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

package com.algorand.android.modules.swap.reddot.data.repository

import com.algorand.android.modules.swap.reddot.data.local.SwapFeatureRedDotPreferenceLocalSource
import com.algorand.android.modules.swap.reddot.data.local.SwapFeatureRedDotPreferenceLocalSource.Companion.defaultSwapFeatureRedDotPreference
import com.algorand.android.modules.swap.reddot.domain.repository.SwapFeatureRedDotRepository

class SwapFeatureRedDotRepositoryImpl(
    private val swapFeatureRedDotPreferenceLocalSource: SwapFeatureRedDotPreferenceLocalSource
) : SwapFeatureRedDotRepository {

    override suspend fun getSwapFeatureRedDotVisibility(): Boolean {
        return swapFeatureRedDotPreferenceLocalSource.getData(defaultSwapFeatureRedDotPreference)
    }

    override suspend fun setSwapFeatureRedDotVisibility(isVisible: Boolean) {
        swapFeatureRedDotPreferenceLocalSource.saveData(isVisible)
    }
}
