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
import android.view.Gravity.CENTER_HORIZONTAL
import android.widget.LinearLayout
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.databinding.CustomErrorListViewBinding
import com.algorand.android.utils.viewbinding.viewBinding

class ErrorListView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private var tryAgainAction: (() -> Unit)? = null

    private val binding = viewBinding(CustomErrorListViewBinding::inflate)

    init {
        gravity = CENTER_HORIZONTAL
        orientation = VERTICAL
        binding.tryAgainButton.setOnClickListener { tryAgainAction?.invoke() }
    }

    fun setTryAgainAction(tryAgainAction: () -> Unit) {
        this.tryAgainAction = tryAgainAction
    }

    fun setupError(type: Type) {
        with(type) {
            binding.iconImageView.setImageResource(iconResId)
            binding.titleTextView.setText(titleResId)
            binding.descriptionTextView.setText(descriptionResId)
        }
    }

    enum class Type(
        @DrawableRes val iconResId: Int,
        @StringRes val titleResId: Int,
        @StringRes val descriptionResId: Int
    ) {
        CONNECTION_ERROR(R.drawable.ic_no_connection, R.string.connect_to_internet, R.string.we_couldn_t_reach),
        DEFAULT_ERROR(R.drawable.ic_error_warning, R.string.something_went_wrong, R.string.sorry_something_went)
    }
}
