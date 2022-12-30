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

package com.algorand.android.customviews.customsnackbar

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.algorand.android.databinding.CustomSnackbarViewBinding
import com.algorand.android.utils.createSnackbar
import com.algorand.android.utils.extensions.invisible
import com.algorand.android.utils.extensions.show
import com.google.android.material.snackbar.Snackbar

class CustomSnackbar private constructor() {

    @DrawableRes
    private var startIconResId: Int? = null

    @StringRes
    private var titleTextResId: Int? = null

    @StringRes
    private var descriptionTextResId: Int? = null

    @StringRes
    private var actionButtonTextResId: Int? = null

    private var actionButtonClickListener: (Snackbar.() -> Unit)? = null

    fun show(rootView: ViewGroup) {
        createCustomSnackbar(
            rootView = rootView,
            applyParams = {
                with(it.infoImageView) {
                    startIconResId?.let { iconResId ->
                        setImageResource(iconResId)
                        show()
                    }
                }
                with(it.titleTextView) {
                    titleTextResId?.let { textResId ->
                        setText(textResId)
                        show()
                    }
                }
                with(it.descriptionTextView) {
                    descriptionTextResId?.let { textResId ->
                        setText(textResId)
                        show()
                    }
                }
                with(it.actionButton) {
                    setOnClickListener { actionButtonClickListener?.invoke(this@createCustomSnackbar) }
                    actionButtonTextResId?.let { textResId ->
                        setText(textResId)
                        show()
                    }
                }
            }
        ).apply {
            show()
        }
    }

    private fun createCustomSnackbar(
        rootView: ViewGroup,
        applyParams: Snackbar.(CustomSnackbarViewBinding) -> Unit
    ): Snackbar {
        return createSnackbar(INITIAL_TEXT, rootView).apply {
            with(view as? Snackbar.SnackbarLayout ?: return@apply) {
                setPadding(0, 0, 0, 0)
                findViewById<android.widget.TextView>(com.algorand.android.R.id.snackbar_text).invisible()
                CustomSnackbarViewBinding.inflate(LayoutInflater.from(rootView.context), rootView, false).apply {
                    applyParams(this)
                }.also {
                    addView(it.root, 0)
                }
            }
        }
    }

    data class Builder(
        @StringRes private var titleTextResId: Int? = null,
        @StringRes private var descriptionTextResId: Int? = null,
        @StringRes private var actionButtonTextResId: Int? = null,
        private var actionButtonClickListener: (Snackbar.() -> Unit)? = null
    ) {

        fun setTitleTextResId(@StringRes titleTextResId: Int?): Builder {
            this.titleTextResId = titleTextResId
            return this
        }

        fun setDescriptionTextResId(@StringRes descriptionTextResId: Int?): Builder {
            this.descriptionTextResId = descriptionTextResId
            return this
        }

        fun setActionButtonTextResId(@StringRes actionButtonTextResId: Int?): Builder {
            this.actionButtonTextResId = actionButtonTextResId
            return this
        }

        fun setActionButtonClickListener(actionButtonClickListener: (Snackbar.() -> Unit)): Builder {
            this.actionButtonClickListener = actionButtonClickListener
            return this
        }

        fun build(): CustomSnackbar {
            return CustomSnackbar().apply {
                titleTextResId = this@Builder.titleTextResId
                descriptionTextResId = this@Builder.descriptionTextResId
                actionButtonTextResId = this@Builder.actionButtonTextResId
                actionButtonClickListener = this@Builder.actionButtonClickListener
            }
        }
    }

    companion object {
        private const val INITIAL_TEXT = ""
    }
}
