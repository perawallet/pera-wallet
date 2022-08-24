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

import javax.inject.Inject
import kotlin.properties.Delegates

open class ListQueuingHelper<E, D> @Inject constructor() {

    val currentItem: E?
        get() = _currentItem

    private val dequeuedItemList = mutableListOf<D?>()
    private var enqueuedItemCount = -1
    private val enqueuedItemList = mutableListOf<E>()
    private var _currentItem: E? by Delegates.observable(null) { _, _, newValue ->
        if (newValue != null) listener?.onNextItemToBeDequeued(newValue)
    }

    protected var listener: Listener<E, D>? = null

    private val areAllItemsDequeued: Boolean
        get() = enqueuedItemCount == dequeuedItemList.size && enqueuedItemCount != -1

    fun initListener(listener: Listener<E, D>) {
        this.listener = listener
    }

    fun initItemsToBeEnqueued(enqueuedItems: List<E>) {
        clearCachedData()
        enqueuedItemList.addAll(enqueuedItems)
        enqueuedItemCount = enqueuedItemList.size
        dequeueFirstItem()
    }

    fun cacheDequeuedItem(dequeuedItem: D?) {
        dequeuedItemList.add(dequeuedItem)
        if (areAllItemsDequeued) {
            listener?.onAllItemsDequeued(dequeuedItemList.toList())
            clearCachedData()
            return
        }
        dequeueFirstItem()
    }

    fun clearCachedData() {
        dequeuedItemList.clear()
        enqueuedItemList.clear()
        enqueuedItemCount = -1
        _currentItem = null
    }

    fun requeueCurrentItem() {
        _currentItem = currentItem
    }

    private fun dequeueFirstItem() {
        _currentItem = enqueuedItemList.removeFirstOrNull()
    }

    interface Listener<E, D> {
        fun onAllItemsDequeued(dequeuedItemList: List<D?>)
        fun onNextItemToBeDequeued(item: E)
    }
}
