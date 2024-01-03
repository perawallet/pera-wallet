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

import androidx.annotation.DrawableRes
import androidx.appcompat.content.res.AppCompatResources
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import kotlin.properties.Delegates

// TODO remove addDivider and use addCustomDivider in refactor
fun RecyclerView.addDivider(@DrawableRes dividerResId: Int) {
    addItemDecoration(DividerItemDecoration(context, DividerItemDecoration.VERTICAL).apply {
        AppCompatResources.getDrawable(context, R.drawable.horizontal_divider_20dp)?.let { setDrawable(it) }
    })
}

fun RecyclerView.addCustomDivider(
    @DrawableRes drawableResId: Int,
    showLast: Boolean = true,
    divider: BaseCustomDividerItemDecoration
) {
    AppCompatResources.getDrawable(context, drawableResId)?.let { dividerDrawable ->
        addItemDecoration(divider.apply {
            drawable = dividerDrawable
            showLastDivider = showLast
        })
    }
}

fun RecyclerView.addItemVisibilityChangeListener(
    position: Int,
    onItemVisibilityChange: ((isVisible: Boolean) -> Unit)
) {
    addOnScrollListener(object : RecyclerView.OnScrollListener() {
        var isVisible: Boolean? by Delegates.observable(null) { _, oldValue, newValue ->
            if (newValue != oldValue && newValue != null) onItemVisibilityChange.invoke(newValue)
        }

        override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
            super.onScrolled(recyclerView, dx, dy)
            (layoutManager as? LinearLayoutManager)?.let {
                val firstVisiblePosition = it.findFirstVisibleItemPosition()
                val lastVisiblePosition = it.findLastVisibleItemPosition()
                isVisible = position in firstVisiblePosition until lastVisiblePosition + 1
            }
        }
    })
}

fun RecyclerView.scrollToTop() {
    this.scrollToPosition(0)
}
