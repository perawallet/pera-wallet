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

package com.algorand.android.ui.common.listhelper

import androidx.recyclerview.widget.DiffUtil
import com.algorand.android.ui.common.listhelper.viewholders.AddAssetListItem
import com.algorand.android.ui.common.listhelper.viewholders.AssetListItem
import com.algorand.android.ui.common.listhelper.viewholders.HeaderAccountListItem
import com.algorand.android.ui.common.listhelper.viewholders.RemoveAssetListItem

open class BaseAccountListItem {
    enum class ItemType {
        HEADER,
        ASSET,
        REMOVE_ASSET,
        ADD_ASSET,
    }

    class BaseAccountListDiffUtil : DiffUtil.ItemCallback<BaseAccountListItem>() {
        override fun areItemsTheSame(oldItem: BaseAccountListItem, newItem: BaseAccountListItem): Boolean {
            if (oldItem is AssetListItem && newItem is AssetListItem) {
                return oldItem.publicKey == newItem.publicKey &&
                    oldItem.assetInformation.assetId == newItem.assetInformation.assetId
            }

            if (oldItem is AddAssetListItem && newItem is AddAssetListItem) {
                return true
            }

            if (oldItem is HeaderAccountListItem && newItem is HeaderAccountListItem) {
                return oldItem.accountCacheData.account.address == newItem.accountCacheData.account.address
            }

            if (oldItem is RemoveAssetListItem && newItem is RemoveAssetListItem) {
                return oldItem.assetInformation.assetId == newItem.assetInformation.assetId
            }

            return false
        }

        override fun areContentsTheSame(oldItem: BaseAccountListItem, newItem: BaseAccountListItem): Boolean {
            if (oldItem is AssetListItem && newItem is AssetListItem) {
                return oldItem.assetInformation.shortName == newItem.assetInformation.shortName &&
                    oldItem.assetInformation.fullName == newItem.assetInformation.fullName &&
                    oldItem.assetInformation.amount == newItem.assetInformation.amount &&
                    oldItem.roundedCornerNeeded == newItem.roundedCornerNeeded
            }

            if (oldItem is AddAssetListItem && newItem is AddAssetListItem) {
                return true
            }

            if (oldItem is HeaderAccountListItem && newItem is HeaderAccountListItem) {
                return oldItem.accountCacheData.account.name == newItem.accountCacheData.account.name &&
                    oldItem.accountCacheData.authAddress == newItem.accountCacheData.authAddress &&
                    oldItem.accountCacheData.account.type == newItem.accountCacheData.account.type
            }

            if (oldItem is RemoveAssetListItem && newItem is RemoveAssetListItem) {
                return oldItem.assetInformation.shortName == newItem.assetInformation.shortName &&
                    oldItem.assetInformation.fullName == newItem.assetInformation.fullName
            }

            return false
        }
    }
}
