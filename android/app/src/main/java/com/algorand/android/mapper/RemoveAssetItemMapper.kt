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
 */

package com.algorand.android.mapper

import com.algorand.android.R
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.RemoveAssetItem
import javax.inject.Inject

class RemoveAssetItemMapper @Inject constructor() {

    fun mapTo(ownedAssetData: BaseAccountAssetData.OwnedAssetData): RemoveAssetItem {
        return with(ownedAssetData) {
            RemoveAssetItem(
                id = id,
                name = name,
                shortName = shortName,
                isVerified = isVerified,
                isAlgo = isAlgo,
                amount = amount,
                creatorPublicKey = creatorPublicKey,
                decimals = decimals,
                formattedAmount = formattedAmount,
                formattedSelectedCurrencyValue = formattedSelectedCurrencyValue,
                isAmountInSelectedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                notAvailableResId = R.string.not_available_shortened
            )
        }
    }
}
