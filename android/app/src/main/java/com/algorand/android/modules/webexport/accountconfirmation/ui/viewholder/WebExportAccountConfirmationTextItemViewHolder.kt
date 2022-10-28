/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.modules.webexport.accountconfirmation.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.updateLayoutParams
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemTextSimpleBinding
import com.algorand.android.modules.webexport.accountconfirmation.ui.model.BaseAccountConfirmationListItem

class WebExportAccountConfirmationTextItemViewHolder(
    private val binding: ItemTextSimpleBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: BaseAccountConfirmationListItem.TextItem) {
        binding.textView.apply {
            setText(item.textResId)
            setTextAppearance(item.textAppearanceResId)
            item.textColorRestId?.let { setTextColor(context.getColor(it)) }
            val topMargin = item.topMarginResId ?: 0
            val bottomMargin = item.bottomMarginResId ?: 0
            if (topMargin != 0 || bottomMargin != 0) {
                updateLayoutParams<ViewGroup.MarginLayoutParams> {
                    setMargins(
                        0,
                        if (topMargin != 0) resources.getDimensionPixelSize(topMargin) else 0,
                        0,
                        if (bottomMargin != 0) resources.getDimensionPixelSize(bottomMargin) else 0
                    )
                }
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): WebExportAccountConfirmationTextItemViewHolder {
            val binding =
                ItemTextSimpleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return WebExportAccountConfirmationTextItemViewHolder(binding)
        }
    }
}
