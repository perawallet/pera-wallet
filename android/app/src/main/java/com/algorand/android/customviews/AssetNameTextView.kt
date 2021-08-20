/*
 * Copyright 2019 Algorand, Inc.
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
import android.text.SpannableStringBuilder
import android.util.AttributeSet
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.res.use
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.CustomAssetNameBinding
import com.algorand.android.models.AssetInformation
import com.algorand.android.utils.addUnnamedAssetName
import com.algorand.android.utils.viewbinding.viewBinding
import java.util.Locale

class AssetNameTextView @JvmOverloads constructor(
    context: Context,
    val attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private var showId: Boolean = false
    private var showAlgoIcon: Boolean = true

    private val binding = viewBinding(CustomAssetNameBinding::inflate)

    init {
        initAttributes()
    }

    private fun initAttributes() {
        context.obtainStyledAttributes(attrs, R.styleable.AssetNameTextView).use {
            showId = it.getBoolean(R.styleable.AssetNameTextView_showId, false)
            showAlgoIcon = it.getBoolean(R.styleable.AssetNameTextView_showAlgoIcon, true)
            binding.subTextView.isVisible = it.getBoolean(R.styleable.AssetNameTextView_showSubText, false)
            if (it.getBoolean(R.styleable.AssetNameTextView_anchorTextsToEnd, false)) {
                enableTextAnchorsToEnd()
            }
        }
    }

    fun setupUI(
        showVerified: Boolean?,
        shortName: String?,
        fullName: String?,
        assetId: Long?,
        isAlgorand: Boolean?,
        addDotSeparator: Boolean = true
    ) {
        binding.verifiedImageView.isVisible = showVerified ?: false
        binding.assetIconImageView.isVisible = showAlgoIcon && (isAlgorand ?: false)

        val isFullNameAvailable = fullName.isNullOrBlank().not()
        val isShortNameAvailable = shortName.isNullOrBlank().not()

        val subTextStringBuilder = StringBuilder()

        if (isFullNameAvailable) {
            binding.mainTextView.text = fullName
            if (isShortNameAvailable) {
                subTextStringBuilder.append(shortName?.toUpperCase(Locale.ENGLISH))
            }
        } else if (isShortNameAvailable) {
            binding.mainTextView.text = shortName?.toUpperCase(Locale.ENGLISH)
        } else {
            binding.mainTextView.text = SpannableStringBuilder().apply { addUnnamedAssetName(context) }
        }

        if (showId && isAlgorand == false) {
            with(subTextStringBuilder) {
                if (isNotEmpty() && addDotSeparator) append(" ·")
                append(" $assetId")
            }
        }

        val subText = subTextStringBuilder.toString()

        binding.subTextView.visibility = if (subText.isNotBlank()) {
            binding.subTextView.text = subTextStringBuilder.toString()
            View.VISIBLE
        } else {
            View.GONE
        }
    }

    fun setupUI(assetInformation: AssetInformation, addDotSeparator: Boolean = true) {
        with(assetInformation) {
            setupUI(isVerified, shortName, fullName, assetId, isAlgorand(), addDotSeparator)
        }
    }

    private fun enableTextAnchorsToEnd() {
        ConstraintSet().apply {
            clone(this@AssetNameTextView)
            constrainWidth(R.id.subTextView, ConstraintSet.WRAP_CONTENT)
            setHorizontalBias(R.id.subTextView, 1f)
            constrainedWidth(R.id.subTextView, true)
            setHorizontalBias(R.id.mainTextView, 1f)
            constrainedWidth(R.id.mainTextView, true)
            constrainWidth(R.id.mainTextView, ConstraintSet.WRAP_CONTENT)
            applyTo(this@AssetNameTextView)
        }
    }
}
