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
import android.graphics.drawable.ShapeDrawable
import android.graphics.drawable.shapes.OvalShape
import android.net.Uri
import android.util.AttributeSet
import androidx.annotation.DimenRes
import androidx.appcompat.widget.AppCompatImageView
import androidx.core.content.ContextCompat
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.models.AccountIcon
import com.algorand.android.utils.loadCircularImage

class AccountIconImageView(context: Context, attrs: AttributeSet? = null) : AppCompatImageView(context, attrs) {

    init {
        initRootView()
    }

    fun setAccountIcon(accountIcon: AccountIcon, @DimenRes padding: Int = R.dimen.spacing_xsmall) {
        accountIcon.apply {
            updatePadding(padding)
            setImageResource(iconDrawable)
            imageTintList = ColorStateList.valueOf(ContextCompat.getColor(context, iconTintResId))
            backgroundTintList = ColorStateList.valueOf(ContextCompat.getColor(context, backgroundColorResId))
        }
    }

    fun setPlaceholder(@DimenRes padding: Int) {
        updatePadding(padding)
        setImageResource(R.drawable.ic_user_placeholder)
        imageTintList = ColorStateList.valueOf(ContextCompat.getColor(context, R.color.secondaryIconTintColor))
        backgroundTintList = ColorStateList.valueOf(ContextCompat.getColor(context, R.color.layerGrayLighter))
    }

    fun loadAccountImage(uri: Uri? = null, @DimenRes padding: Int = R.dimen.spacing_xsmall) {
        if (uri != null) {
            clearViewAttrs()
            loadCircularImage(uri)
        } else {
            loadAccountPlaceHolder(padding)
        }
    }

    fun loadAccountPlaceHolder(@DimenRes padding: Int) {
        setPlaceholder(padding)
    }

    // We have to remove padding and tint attrs to load image properly
    private fun clearViewAttrs() {
        updatePadding(R.dimen.spacing_zero)
        setImageDrawable(null)
        imageTintList = null
        backgroundTintList = null
    }

    private fun updatePadding(@DimenRes padding: Int) {
        setPadding(resources.getDimensionPixelSize(padding))
    }

    private fun initRootView() {
        background = ShapeDrawable(OvalShape())
    }
}
