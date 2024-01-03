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

package com.algorand.android.utils.extensions

import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AssetHolding
import com.algorand.android.models.AssetStatus

fun AccountDetail.getAssetHoldingOrNull(assetId: Long): AssetHolding? {
    return accountInformation.getAssetHoldingOrNull(assetId)
}

fun AccountDetail.getAssetStatusOrNull(assetId: Long): AssetStatus? {
    return accountInformation.getAssetStatusOrNull(assetId)
}

fun AccountDetail.hasAsset(assetId: Long): Boolean {
    return accountInformation.hasAsset(assetId)
}

fun AccountDetail.getAssetHoldingList(): List<AssetHolding> {
    return accountInformation.getAssetHoldingList()
}

fun AccountDetail.getAssetIdList(): List<Long> {
    return accountInformation.getAssetIdList().toList()
}
