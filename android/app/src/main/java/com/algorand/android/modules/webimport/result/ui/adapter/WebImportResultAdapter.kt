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

package com.algorand.android.modules.webimport.result.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.R
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.webimport.result.ui.model.BaseAccountResultListItem
import com.algorand.android.modules.webimport.result.ui.viewholder.WebImportResultAccountItemViewHolder
import com.algorand.android.modules.webimport.result.ui.viewholder.WebImportResultImageItemViewHolder
import com.algorand.android.modules.webimport.result.ui.viewholder.WebImportResultTextItemViewHolder
import com.algorand.android.modules.webimport.result.ui.viewholder.WebImportResultWarningBoxItemViewHolder

class WebImportResultAdapter :
    ListAdapter<BaseAccountResultListItem,
        BaseViewHolder<BaseAccountResultListItem>>(BaseDiffUtil<BaseAccountResultListItem>()) {

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            is BaseAccountResultListItem.TextItem -> R.layout.item_text_simple
            is BaseAccountResultListItem.AccountItem -> R.layout.item_account
            is BaseAccountResultListItem.ImageItem -> R.layout.item_image_simple
            is BaseAccountResultListItem.WarningBoxItem -> R.layout.item_card_simple
            else -> throw Exception("$logTag list item is unknown")
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseAccountResultListItem> {
        return when (viewType) {
            R.layout.item_text_simple -> createTextItemViewHolder(parent)
            R.layout.item_account -> createImportedAccountItemViewHolder(parent)
            R.layout.item_image_simple -> createImageItemViewHolder(parent)
            R.layout.item_card_simple -> createWarningBoxItemViewHolder(parent)
            else -> throw Exception("$logTag list item is unknown")
        }
    }

    private fun createImportedAccountItemViewHolder(parent: ViewGroup): WebImportResultAccountItemViewHolder {
        return WebImportResultAccountItemViewHolder.create(parent = parent)
    }

    private fun createTextItemViewHolder(parent: ViewGroup): WebImportResultTextItemViewHolder {
        return WebImportResultTextItemViewHolder.create(parent)
    }

    private fun createImageItemViewHolder(parent: ViewGroup): WebImportResultImageItemViewHolder {
        return WebImportResultImageItemViewHolder.create(parent)
    }

    private fun createWarningBoxItemViewHolder(parent: ViewGroup): WebImportResultWarningBoxItemViewHolder {
        return WebImportResultWarningBoxItemViewHolder.create(parent)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseAccountResultListItem>, position: Int) {
        holder.bind(getItem(position))
    }

    companion object {
        private val logTag = WebImportResultAdapter::class.java
    }
}
