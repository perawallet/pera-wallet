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

package com.algorand.android.modules.registration.watchaccount.ui.adapter

import android.text.style.AbsoluteSizeSpan
import android.text.style.ForegroundColorSpan
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountAddressBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.registration.watchaccount.ui.model.BasePasteableWatchAccountItem
import com.algorand.android.utils.getXmlStyledString

class AccountAddressItemViewHolder(
    private val binding: ItemAccountAddressBinding,
    private val listener: Listener
) : BaseViewHolder<BasePasteableWatchAccountItem>(binding.root) {

    override fun bind(item: BasePasteableWatchAccountItem) {
        if (item !is BasePasteableWatchAccountItem.AccountAddressItem) return
        with(binding.pasteAddressButton) {
            text = createAnnotatedStringOfItem(item.shortenedAccountAddress)
            setOnClickListener { listener.onAccountAddressClick(item.accountAddress) }
        }
    }

    private fun createAnnotatedStringOfItem(shortenedAccountAddress: String): CharSequence? {
        val accountTextColor = ContextCompat.getColor(binding.root.context, R.color.secondary_text_color)
        val accountTextSize = binding.root.resources.getDimensionPixelSize(R.dimen.text_size_11)
        return binding.root.context?.getXmlStyledString(
            stringResId = R.string.paste_with_account,
            replacementList = listOf("account" to shortenedAccountAddress),
            customAnnotations = listOf(
                "account_color" to ForegroundColorSpan(accountTextColor),
                "account_text_size" to AbsoluteSizeSpan(accountTextSize)
            )
        )
    }

    fun interface Listener {
        fun onAccountAddressClick(accountAddress: String)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): AccountAddressItemViewHolder {
            val binding = ItemAccountAddressBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountAddressItemViewHolder(binding, listener)
        }
    }
}
