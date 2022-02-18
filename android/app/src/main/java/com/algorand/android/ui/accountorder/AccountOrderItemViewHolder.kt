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

package com.algorand.android.ui.accountorder

import android.annotation.SuppressLint
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.ViewGroup
import com.algorand.android.databinding.ItemAccountOrderBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.models.ui.AccountOrderItem

class AccountOrderItemViewHolder(
    private val binding: ItemAccountOrderBinding,
    private val listener: DragButtonPressedListener
) : BaseViewHolder<AccountOrderItem>(binding.root) {

    override fun bind(item: AccountOrderItem) {
        with(binding) {
            displayNameTextView.text = item.displayName
            accountIconImageView.setAccountIcon(item.accountIcon)
        }
        initDragButton()
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun initDragButton() {
        binding.dragButton.setOnTouchListener { v, event ->
            if (event.actionMasked == MotionEvent.ACTION_MOVE || event.actionMasked == MotionEvent.ACTION_DOWN) {
                listener.onPressed(this@AccountOrderItemViewHolder)
            }
            false
        }
    }

    fun interface DragButtonPressedListener {
        fun onPressed(viewHolder: AccountOrderItemViewHolder)
    }

    companion object {
        fun create(parent: ViewGroup, listener: DragButtonPressedListener): AccountOrderItemViewHolder {
            val binding = ItemAccountOrderBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountOrderItemViewHolder(binding, listener)
        }
    }
}
