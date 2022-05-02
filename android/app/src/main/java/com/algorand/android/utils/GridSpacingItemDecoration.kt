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

package com.algorand.android.utils

import android.graphics.Rect
import android.view.View
import androidx.recyclerview.widget.RecyclerView

class GridSpacingItemDecoration(
    private val spanCount: Int,
    private val spacingAsPx: Int,
    private val includeEdge: Boolean
) : RecyclerView.ItemDecoration() {

    override fun getItemOffsets(outRect: Rect, view: View, parent: RecyclerView, state: RecyclerView.State) {
        val itemPosition = parent.getChildAdapterPosition(view)
        val column = itemPosition % spanCount
        if (includeEdge) {
            outRect.left = spacingAsPx - column * spacingAsPx / spanCount
            outRect.right = (column + 1) * spacingAsPx / spanCount
            if (itemPosition < spanCount) {
                outRect.top = spacingAsPx
            }
            outRect.bottom = spacingAsPx
        } else {
            outRect.left = column * spacingAsPx / spanCount
            outRect.right = spacingAsPx - (column + 1) * spacingAsPx / spanCount
            if (itemPosition >= spanCount) {
                outRect.top = spacingAsPx
            }
        }
    }
}
