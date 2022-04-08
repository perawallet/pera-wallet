/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.ledgersearch.instructions

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemLedgerInstructionStepBinding
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.setXmlStyledString

class LedgerInstructionStepViewHolder(
    private val binding: ItemLedgerInstructionStepBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(instructionStepText: Int, position: Int) {
        with(binding) {
            stepNumberTextView.text = root.context?.getXmlStyledString(
                R.string.position_with_dot,
                listOf("position" to (position + 1).toString())
            )
            descriptionTextView.setXmlStyledString(instructionStepText, R.color.link_primary, ::onUrlClick)
        }
    }

    private fun onUrlClick(url: String) {
        if (url.isNotBlank()) {
            binding.descriptionTextView.context.openUrl(url)
        }
    }

    companion object {
        fun create(parent: ViewGroup): LedgerInstructionStepViewHolder {
            val binding = ItemLedgerInstructionStepBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return LedgerInstructionStepViewHolder(binding)
        }
    }
}
