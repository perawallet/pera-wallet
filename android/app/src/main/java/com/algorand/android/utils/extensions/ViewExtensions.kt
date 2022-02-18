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

package com.algorand.android.utils.extensions

import android.graphics.PorterDuff
import android.graphics.PorterDuffColorFilter
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.annotation.StyleRes
import androidx.core.content.ContextCompat
import androidx.core.view.get
import androidx.core.view.isVisible
import com.google.android.material.button.MaterialButton
import com.google.android.material.tabs.TabLayout
import com.google.android.material.textview.MaterialTextView

fun View.show() {
    this.visibility = View.VISIBLE
}

fun View.hide() {
    this.visibility = View.GONE
}

fun View.invisible() {
    this.visibility = View.INVISIBLE
}

fun ImageView.setImageResAndVisibility(@DrawableRes imageResId: Int?) {
    if (imageResId != null && imageResId != -1) {
        setImageResource(imageResId)
    }
    isVisible = imageResId != null && imageResId != -1
}

fun TextView.setTextAndVisibility(text: String?) {
    setText(text)
    isVisible = text.isNullOrEmpty().not()
}

fun TextView.setTextAndVisibility(@StringRes stringRes: Int?) {
    if (stringRes != null && stringRes != -1) {
        setText(stringRes)
    }
    isVisible = stringRes != null && stringRes != -1
}

fun MaterialButton.setTextAndVisibility(@StringRes stringRes: Int?) {
    if (stringRes != null && stringRes != -1) {
        setText(stringRes)
    }
    isVisible = stringRes != null && stringRes != -1
}

fun MaterialButton.setIconAndVisibility(@DrawableRes iconResId: Int?, @ColorRes iconColorResId: Int = -1) {
    if (iconResId != null && iconResId != -1) {
        setIconResource(iconResId)
    }
    isVisible = iconResId != null && iconResId != -1

    if (iconColorResId != -1) {
        setIconTintResource(iconColorResId)
    }
}

fun TabLayout.Tab?.changeTabTextAppearance(@StyleRes styleRes: Int) {
    if ((this?.view?.childCount ?: 0) >= 2 && this?.view?.get(1) is MaterialTextView) {
        val textView = view[1] as MaterialTextView
        textView.changeTextAppearance(styleRes)
    }
}

fun TextView.changeTextAppearance(@StyleRes styleRes: Int) {
    setTextAppearance(styleRes)
}

fun TextView.setClickActionAndVisibility(action: () -> Unit) {
    setOnClickListener { action.invoke() }
    show()
}

fun TextView.setDrawableTintColor(@ColorRes colorRes: Int) {
    val color = ContextCompat.getColor(context, colorRes)
    compoundDrawablesRelative.forEach {
        if (it != null) {
            it.colorFilter = PorterDuffColorFilter(color, PorterDuff.Mode.SRC_IN)
        }
    }
}
