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

package com.algorand.android.modules.basefoundaccount.information.ui.model

import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider

sealed class BaseFoundAccountInformationItem : RecyclerListItem {

    enum class ItemType {
        TITLE_ITEM,
        ACCOUNT_ITEM,
        ASSET_ITEM
    }

    abstract val itemType: ItemType

    data class TitleItem(
        val titleTextResId: Int
    ) : BaseFoundAccountInformationItem() {

        override val itemType: ItemType
            get() = ItemType.TITLE_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && titleTextResId == other.titleTextResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && this == other
        }
    }

    data class AccountItem(
        val accountDisplayName: AccountDisplayName,
        val accountIconDrawablePreview: AccountIconDrawablePreview,
        val formattedPrimaryValue: String?,
        val formattedSecondaryValue: String?
    ) : BaseFoundAccountInformationItem() {

        override val itemType: ItemType
            get() = ItemType.ACCOUNT_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem &&
                accountDisplayName.getRawAccountAddress() == other.accountDisplayName.getRawAccountAddress()
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem && this == other
        }
    }

    data class AssetItem(
        val assetId: Long,
        val name: AssetName,
        val shortName: AssetName,
        val verificationTierConfiguration: VerificationTierConfiguration,
        val baseAssetDrawableProvider: BaseAssetDrawableProvider,
        val formattedPrimaryValue: String?,
        val formattedSecondaryValue: String?
    ) : BaseFoundAccountInformationItem() {

        override val itemType: ItemType
            get() = ItemType.ASSET_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AssetItem && assetId == other.assetId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AssetItem && this == other
        }
    }
}
