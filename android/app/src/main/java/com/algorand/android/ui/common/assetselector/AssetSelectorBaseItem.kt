/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.common.assetselector

import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation

sealed class AssetSelectorBaseItem {

    data class AssetSelectorHeaderItem(val accountCacheData: AccountCacheData) : AssetSelectorBaseItem()

    data class AssetSelectorItem(
        val accountCacheData: AccountCacheData,
        val assetInformation: AssetInformation,
        val showDivider: Boolean
    ) : AssetSelectorBaseItem()

    enum class Type {
        HEADER,
        ASSET_ITEM
    }
}
