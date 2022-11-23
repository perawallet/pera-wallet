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

package com.algorand.android.modules.swap.assetswap.data.mapper.decider

import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapType
import com.algorand.android.modules.swap.assetswap.data.model.SwapTypeResponse
import javax.inject.Inject

class SwapTypeDecider @Inject constructor() {

    fun decideSwapType(response: SwapTypeResponse?): SwapType {
        return when (response) {
            SwapTypeResponse.FIXED_INPUT -> SwapType.FIXED_INPUT
            SwapTypeResponse.FIXED_OUTPUT -> SwapType.FIXED_OUTPUT
            SwapTypeResponse.UNKNOWN, null -> SwapType.UNKNOWN
        }
    }
}
