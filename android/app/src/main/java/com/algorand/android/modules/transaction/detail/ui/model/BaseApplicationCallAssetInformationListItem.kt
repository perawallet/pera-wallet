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

package com.algorand.android.modules.transaction.detail.ui.model

import com.algorand.android.customviews.accountandassetitem.model.BaseItemConfiguration
import com.algorand.android.models.RecyclerListItem

sealed class BaseApplicationCallAssetInformationListItem : RecyclerListItem {

    enum class ItemType {
        ASSET_INFORMATION
    }

    abstract val itemType: ItemType

    data class AssetInformationItem(
        val assetItemConfiguration: BaseItemConfiguration.BaseAssetItemConfiguration.AssetItemConfiguration
    ) : BaseApplicationCallAssetInformationListItem() {

        override val itemType: ItemType = ItemType.ASSET_INFORMATION

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AssetInformationItem &&
                assetItemConfiguration.assetId == other.assetItemConfiguration.assetId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AssetInformationItem && this == other
        }
    }
}
