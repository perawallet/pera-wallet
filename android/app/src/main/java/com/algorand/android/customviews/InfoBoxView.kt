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
import android.content.res.ColorStateList
import android.util.AttributeSet
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomInfoBoxBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.PluralAnnotatedString
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getXmlStyledPluralString
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding

class InfoBoxView @JvmOverloads constructor(
    context: Context,
    attributeSet: AttributeSet? = null
) : ConstraintLayout(context, attributeSet) {

    private val binding = viewBinding(CustomInfoBoxBinding::inflate)

    init {
        initRootView()
    }

    fun setBackgroundTint(@ColorRes tintResId: Int) {
        backgroundTintList = ColorStateList.valueOf(ContextCompat.getColor(context, tintResId))
    }

    fun setInfoIcon(@DrawableRes iconResId: Int, @ColorRes tintResId: Int) {
        binding.infoIconImageView.apply {
            setImageResource(iconResId)
            imageTintList = ColorStateList.valueOf(ContextCompat.getColor(context, tintResId))
            show()
        }
    }

    fun setInfoTitle(@StringRes titleResId: Int, @ColorRes tintResId: Int) {
        binding.infoTitleTextView.apply {
            setText(titleResId)
            setTextColor(ContextCompat.getColor(context, tintResId))
            show()
        }
    }

    fun setInfoDescription(annotatedString: AnnotatedString, @ColorRes tintResId: Int) {
        binding.infoDescriptionTextView.apply {
            text = context.getXmlStyledString(annotatedString)
            setTextColor(ContextCompat.getColor(context, tintResId))
            show()
        }
    }

    fun setInfoDescription(pluralAnnotatedString: PluralAnnotatedString, @ColorRes tintResId: Int) {
        binding.infoDescriptionTextView.apply {
            text = context.getXmlStyledPluralString(pluralAnnotatedString)
            setTextColor(ContextCompat.getColor(context, tintResId))
            show()
        }
    }

    private fun initRootView() {
        setPadding(resources.getDimensionPixelSize(R.dimen.spacing_normal))
        setBackgroundResource(R.drawable.bg_rectangle_radius_8)
    }
}
