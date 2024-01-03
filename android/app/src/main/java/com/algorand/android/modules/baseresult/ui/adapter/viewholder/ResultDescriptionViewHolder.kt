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

package com.algorand.android.modules.baseresult.ui.adapter.viewholder

import android.text.method.LinkMovementMethod
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.databinding.ItemResultDescriptionBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.baseresult.ui.model.ResultListItem
import com.algorand.android.utils.getCustomClickableSpan
import com.algorand.android.utils.getXmlStyledPluralString
import com.algorand.android.utils.getXmlStyledString

/**
 * The only limitation of this holder, there could be only one annotated text that could be clickable.
 */
class ResultDescriptionViewHolder(
    private val binding: ItemResultDescriptionBinding,
    private val listener: Listener
) : BaseViewHolder<ResultListItem>(binding.root) {

    override fun bind(item: ResultListItem) {
        if (item !is ResultListItem.DescriptionItem) return
        when (item) {
            is ResultListItem.DescriptionItem.Singular -> bindSingularDescription(item)
            is ResultListItem.DescriptionItem.Plural -> bindPluralDescription(item)
        }
    }

    private fun bindPluralDescription(item: ResultListItem.DescriptionItem.Plural) {
        binding.resultDescriptionTextView.apply {
            val customAnnotationList = item.pluralAnnotatedString.customAnnotationList.toMutableList()
            if (item.isClickable) {
                movementMethod = LinkMovementMethod.getInstance()

                val linkTextColor = ContextCompat.getColor(context, R.color.positive)
                val learnMoreClickSpannable = getCustomClickableSpan(
                    clickableColor = linkTextColor,
                    onClick = { listener.onDescriptionUrlClick() }
                )
                customAnnotationList.add(URL_CLICK_ANNOTATION_KEY to learnMoreClickSpannable)
            } else {
                movementMethod = null
            }
            val modifiedAnnotatedString = item.pluralAnnotatedString.copy(customAnnotationList = customAnnotationList)
            text = context?.getXmlStyledPluralString(modifiedAnnotatedString)
        }
    }

    private fun bindSingularDescription(item: ResultListItem.DescriptionItem.Singular) {
        binding.resultDescriptionTextView.apply {
            val customAnnotationList = item.annotatedString.customAnnotationList.toMutableList()
            if (item.isClickable) {
                highlightColor = ContextCompat.getColor(context, R.color.transparent)
                movementMethod = LinkMovementMethod.getInstance()

                val linkTextColor = ContextCompat.getColor(context, R.color.positive)
                val learnMoreClickSpannable = getCustomClickableSpan(
                    clickableColor = linkTextColor,
                    onClick = { listener.onDescriptionUrlClick() }
                )
                customAnnotationList.add(URL_CLICK_ANNOTATION_KEY to learnMoreClickSpannable)
            }
            val modifiedAnnotatedString = item.annotatedString.copy(customAnnotationList = customAnnotationList)
            text = context?.getXmlStyledString(modifiedAnnotatedString)
        }
    }

    fun interface Listener {
        fun onDescriptionUrlClick()
    }

    companion object {
        private const val URL_CLICK_ANNOTATION_KEY = "url_click"

        fun create(parent: ViewGroup, listener: Listener): ResultDescriptionViewHolder {
            val binding = ItemResultDescriptionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return ResultDescriptionViewHolder(binding, listener)
        }
    }
}
