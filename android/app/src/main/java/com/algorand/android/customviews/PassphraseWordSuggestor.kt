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
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.databinding.CustomPassphraseWordSuggestorBinding
import com.algorand.android.utils.viewbinding.viewBinding

class PassphraseWordSuggestor @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private val binding = viewBinding(CustomPassphraseWordSuggestorBinding::inflate)
    private var index: Int = 0
    var listener: Listener? = null

    init {
        setBackgroundColor(ContextCompat.getColor(context, R.color.secondaryBackground))
        orientation = HORIZONTAL
        setWordClickListener(binding.firstWordTextView)
        setWordClickListener(binding.secondWordTextView)
        setWordClickListener(binding.thirdWordTextView)
    }

    private fun setWordClickListener(wordTextView: TextView) {
        wordTextView.setOnClickListener { view -> onSuggestedWordClick((view as TextView).text.toString()) }
    }

    fun setSuggestedWords(index: Int, words: List<String>) {
        this.index = index
        binding.firstWordTextView.text = words.getOrNull(0).orEmpty()
        binding.secondWordTextView.text = words.getOrNull(1).orEmpty()
        binding.thirdWordTextView.text = words.getOrNull(2).orEmpty()
    }

    private fun onSuggestedWordClick(suggestedWord: String) {
        if (suggestedWord.isNotEmpty()) {
            listener?.onSuggestedWordSelected(index, suggestedWord)
        }
    }

    interface Listener {
        fun onSuggestedWordSelected(index: Int, word: String)
    }
}
