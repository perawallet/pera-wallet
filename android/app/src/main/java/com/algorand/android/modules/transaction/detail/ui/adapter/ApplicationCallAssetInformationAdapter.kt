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

package com.algorand.android.modules.transaction.detail.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.transaction.detail.ui.model.BaseApplicationCallAssetInformationListItem
import com.algorand.android.modules.transaction.detail.ui.viewholder.ApplicationCallAssetInformationViewHolder

class ApplicationCallAssetInformationAdapter : ListAdapter<
    BaseApplicationCallAssetInformationListItem,
    BaseViewHolder<BaseApplicationCallAssetInformationListItem>>(
    BaseDiffUtil()
) {

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): BaseViewHolder<BaseApplicationCallAssetInformationListItem> {
        return when (viewType) {
            BaseApplicationCallAssetInformationListItem.ItemType.ASSET_INFORMATION.ordinal -> {
                createAssetInformationViewHolder(parent)
            }
            else -> throw Exception("$logTag list item is unknown")
        }
    }

    private fun createAssetInformationViewHolder(parent: ViewGroup): ApplicationCallAssetInformationViewHolder {
        return ApplicationCallAssetInformationViewHolder.create(parent)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseApplicationCallAssetInformationListItem>, position: Int) {
        holder.bind(getItem(position))
    }

    companion object {
        private val logTag = ApplicationCallAssetInformationAdapter::class.simpleName
    }
}
