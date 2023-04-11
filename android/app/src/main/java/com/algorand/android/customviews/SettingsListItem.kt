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
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.use
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.CustomSettingsListItemBinding
import com.algorand.android.utils.viewbinding.viewBinding

class SettingsListItem @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomSettingsListItemBinding::inflate)

    private var endComponent: View? = null

    init {
        setLayoutAttributes()
        initAttributes(attrs)
    }

    fun updateSubTitle(charSequence: CharSequence) {
        binding.settingSubTitleTextView.text = charSequence
    }

    fun updateSubTitleVisibility(isVisible: Boolean) {
        binding.settingSubTitleTextView.isVisible = isVisible
    }

    /**
     * CAUTION
     * Ensure your generic model that is the same as that you already inflate in [ViewStub]
     */
    fun <T : View> getEndComponentViewStub(): T? {
        return endComponent as? T
    }

    private fun initAttributes(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.SettingsListItem).use {
            with(binding) {
                it.getText(R.styleable.SettingsListItem_settingTitle)?.let { safeTitle ->
                    settingTitleTextView.text = safeTitle
                }
                it.getText(R.styleable.SettingsListItem_settingSubTitle)?.let { safeSubTitle ->
                    settingSubTitleTextView.text = safeSubTitle
                }
                it.getDrawable(R.styleable.SettingsListItem_settingIcon)?.let { safeIcon ->
                    settingIconImageView.setImageDrawable(safeIcon)
                }
                it.getResourceId(R.styleable.SettingsListItem_endViewLayoutResource, INVALID_RES_ID).takeIf { resId ->
                    resId != INVALID_RES_ID
                }?.run {
                    endComponentViewStub.layoutResource = this
                    endComponent = endComponentViewStub.inflate()
                }
            }
        }
    }

    private fun setLayoutAttributes() {
        minHeight = resources.getDimensionPixelOffset(R.dimen.settings_list_item_min_height)
    }

    companion object {
        private const val INVALID_RES_ID = -1
    }
}
