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

package com.algorand.android.customviews.toolbar.buttoncontainer.model

import android.view.View
import android.widget.ImageButton
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.setDrawable

sealed class BaseAccountIconButton : BaseToolbarButton() {

    abstract val accountIconDrawablePreview: AccountIconDrawablePreview

    data class AccountButton(
        override val accountIconDrawablePreview: AccountIconDrawablePreview,
        override val onClick: () -> Unit
    ) : BaseAccountIconButton() {

        override val layoutResId: Int
            get() = R.layout.custom_icon_tab_button

        override val backgroundTintResId: Int?
            get() = null

        override fun initAttributes(view: View) {
            val drawable = AccountIconDrawable.create(
                context = view.context,
                sizeResId = R.dimen.spacing_xlarge,
                accountIconDrawablePreview = accountIconDrawablePreview
            )
            (view as? ImageButton)?.setImageDrawable(drawable)
        }
    }

    data class ExtendedAccountButton(
        val accountTypeResId: Int,
        override val accountIconDrawablePreview: AccountIconDrawablePreview,
        override val onClick: () -> Unit
    ) : BaseAccountIconButton() {

        override val layoutResId: Int
            get() = R.layout.custom_extended_account_icon_button

        override val backgroundTintResId: Int
            get() = accountIconDrawablePreview.backgroundColorResId

        override fun initAttributes(view: View) {
            val drawable = AccountIconDrawable.create(
                context = view.context,
                sizeResId = R.dimen.spacing_xlarge,
                accountIconDrawablePreview = accountIconDrawablePreview
            )
            (view as? TextView)?.apply {
                setDrawable(start = drawable)
                setText(accountTypeResId)
                setTextColor(ContextCompat.getColor(context, accountIconDrawablePreview.iconTintResId))
                setBackgroundTint(this)
            }
        }
    }
}
