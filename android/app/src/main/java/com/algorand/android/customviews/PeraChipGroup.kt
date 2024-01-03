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

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import androidx.core.view.children
import com.algorand.android.R
import com.google.android.material.chip.Chip
import com.google.android.material.chip.ChipGroup

class PeraChipGroup @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ChipGroup(context, attrs) {

    private var listener: PeraChipGroupListener? = null

    override fun isSelectionRequired(): Boolean {
        return false
    }

    fun setListener(listener: PeraChipGroupListener) {
        this.listener = listener
    }

    fun initPeraChipGroup(peraChipItems: List<PeraChipItem>, checkedPeraChip: PeraChipItem?) {
        if (children.count() != peraChipItems.size) {
            createPeraChipList(peraChipItems, checkedPeraChip)
        } else {
            updateSelectedChip(checkedPeraChip)
        }
    }

    private fun updateSelectedChip(selectedPeraChip: PeraChipItem?) {
        clearCheck()
        children.forEach {
            (it as? PeraChip)?.run {
                isChecked = chipItem?.labelText == selectedPeraChip?.labelText
            }
        }
    }

    private fun createPeraChipList(peraChipItems: List<PeraChipItem>, checkedPeraChip: PeraChipItem?) {
        with(peraChipItems) {
            forEachIndexed { index, peraChipItem ->
                createPeraChip(
                    index = index,
                    peraChipItem = peraChipItem,
                    isChecked = peraChipItem.labelText == checkedPeraChip?.labelText
                ).apply { addView(this) }
            }
        }
    }

    private fun createPeraChip(index: Int, peraChipItem: PeraChipItem, isChecked: Boolean): Chip {
        return PeraChip(peraChipItem, context).apply {
            text = peraChipItem.labelText
            this.isChecked = isChecked
            setOnClickListener { listener?.onCheckChange(peraChipItem, index) }
        }
    }

    interface PeraChipGroupListener {
        fun onCheckChange(peraChipItem: PeraChipItem, selectedChipIndex: Int)
    }

    class PeraChip(context: Context) : Chip(context, null, R.attr.peraChipStyle) {

        var chipItem: PeraChipItem? = null
            private set

        constructor(item: PeraChipItem, context: Context) : this(context) {
            chipItem = item
        }
    }

    interface PeraChipItem {
        val labelText: String
        val value: Any
    }
}
