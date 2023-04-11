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

package com.algorand.android.modules.dapp.bidali.domain.mapper

import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData
import com.algorand.android.modules.dapp.bidali.domain.model.BidaliAsset
import com.algorand.android.modules.dapp.bidali.domain.model.MainnetBidaliSupportedCurrency
import com.algorand.android.modules.dapp.bidali.domain.model.TestnetBidaliSupportedCurrency
import java.math.BigDecimal
import javax.inject.Inject

class BidaliAssetMapper @Inject constructor() {

    fun mapFromOwnedAssetData(
        ownedAssetDataList: List<OwnedAssetData>,
        isMainnet: Boolean
    ): List<BidaliAsset> {
        return if (isMainnet) {
            MainnetBidaliSupportedCurrency.values()
                .map { bidaliCurrency ->
                    val currency = ownedAssetDataList.firstOrNull { it.id == bidaliCurrency.assetId }
                    BidaliAsset.MainnetBidaliAsset(
                        bidaliCurrency,
                        currency?.amount?.toBigDecimal(currency.decimals) ?: BigDecimal.ZERO
                    )
                }
        } else {
            TestnetBidaliSupportedCurrency.values()
                .map { bidaliCurrency ->
                    val currency = ownedAssetDataList.firstOrNull { it.id == bidaliCurrency.assetId }
                    BidaliAsset.TestnetBidaliAsset(
                        bidaliCurrency,
                        currency?.amount?.toBigDecimal(currency.decimals) ?: BigDecimal.ZERO
                    )
                }
        }
    }
}
