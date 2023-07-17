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

import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import kotlin.properties.Delegates

class RecyclerViewPositionVisibilityHandler(position: Int, listener: Listener) {

    private val onScrollListener = object : RecyclerView.OnScrollListener() {
        var isVisible: Boolean? by Delegates.observable(null) { _, oldValue, newValue ->
            if (newValue != oldValue && newValue != null) listener.onItemVisibilityChange(newValue)
        }

        override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
            super.onScrolled(recyclerView, dx, dy)
            (recyclerView.layoutManager as? LinearLayoutManager)?.let {
                val firstVisiblePosition = it.findFirstVisibleItemPosition()
                val lastVisiblePosition = it.findLastVisibleItemPosition()
                isVisible = position in firstVisiblePosition until lastVisiblePosition + 1
            }
        }
    }

    fun addOnScrollListener(recyclerView: RecyclerView) {
        recyclerView.removeOnScrollListener(onScrollListener)
        recyclerView.addOnScrollListener(onScrollListener)
    }

    fun removeOnScrollListener(recyclerView: RecyclerView) {
        recyclerView.removeOnScrollListener(onScrollListener)
    }

    fun interface Listener {
        fun onItemVisibilityChange(isVisible: Boolean)
    }
}
