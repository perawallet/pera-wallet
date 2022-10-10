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

package com.algorand.android.nft.ui.nftlisting

import android.content.Context
import androidx.recyclerview.widget.GridLayoutManager
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.INFO_VIEW_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.SEARCH_VIEW_ITEM
import com.algorand.android.nft.ui.model.BaseCollectibleListItem.ItemType.TITLE_TEXT_VIEW_ITEM

class CollectibleListGridLayoutManager(context: Context, adapter: CollectibleListAdapter) :
    GridLayoutManager(context, RECYCLER_SPAN_COUNT) {

    init {
        spanSizeLookup = object : SpanSizeLookup() {
            override fun getSpanSize(position: Int): Int {
                val itemViewType = adapter.getItemViewType(position)
                return getSpanSizeByItemViewType(itemViewType)
            }
        }
    }

    private fun getSpanSizeByItemViewType(itemType: Int): Int {
        return if (
            itemType == TITLE_TEXT_VIEW_ITEM.ordinal ||
            itemType == SEARCH_VIEW_ITEM.ordinal ||
            itemType == INFO_VIEW_ITEM.ordinal
        ) {
            RECYCLER_SPAN_COUNT
        } else {
            1
        }
    }

    companion object {
        private const val RECYCLER_SPAN_COUNT = 2
    }
}
