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

package com.algorand.android.modules.accountasset.data.mapper

import com.algorand.android.modules.accountasset.data.model.AccountDetailWithoutAssetsResponse
import com.algorand.android.modules.accountasset.domain.model.AccountAssetDetail
import java.math.BigInteger
import javax.inject.Inject

class AccountAssetDetailMapper @Inject constructor() {

    fun map(
        accountWithoutAssetResponse: AccountDetailWithoutAssetsResponse?,
        assetDetail: AccountAssetDetail.AssetDetail?
    ): AccountAssetDetail? {
        return accountWithoutAssetResponse?.run {
            AccountAssetDetail(
                address = address ?: return null,
                algoAmount = amount ?: BigInteger.ZERO,
                minBalanceRequired = minRequiredBalance ?: BigInteger.ZERO,
                assetDetail = assetDetail
            )
        }
    }
}
