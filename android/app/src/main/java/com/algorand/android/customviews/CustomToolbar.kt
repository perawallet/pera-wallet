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
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.CustomToolbarBinding
import com.algorand.android.models.AccountIcon
import com.algorand.android.models.BaseToolbarButton
import com.algorand.android.models.Node
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.ALGOS_SHORT_NAME
import com.algorand.android.utils.TESTNET_NETWORK_SLUG
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.viewbinding.viewBinding
import kotlin.properties.Delegates

class CustomToolbar @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomToolbarBinding::inflate)

    private var isAvatarLayoutVisible by Delegates.observable(false) { _, _, newValue ->
        binding.accountAndAssetAvatarLayout.isVisible = newValue
    }

    private var isAssetAvatarVisible by Delegates.observable(false) { _, _, newValue ->
        binding.assetAvatarView.isVisible = newValue
    }

    private var isAccountImageVisible by Delegates.observable(false) { _, _, newValue ->
        binding.accountImageView.isVisible = newValue
    }

    init {
        initRootView()
    }

    fun configure(toolbarConfiguration: ToolbarConfiguration?) {
        if (toolbarConfiguration == null) {
            hide()
            return
        }
        binding.buttonContainerView.removeAllViews()
        with(toolbarConfiguration) {
            setupBackground(backgroundColor)
            setupTitle(titleResId, titleColor)
            configureStartButton(startIconResId, startIconClick, startIconColor)
            setupCenterImage(centerImageRes)
            val isTestNetStatusActive = binding.nodeStatusTextView.text == TESTNET_NETWORK_SLUG
            binding.nodeStatusTextView.isVisible = showNodeStatus && isTestNetStatusActive
            isAssetAvatarVisible = showAvatarImage
            isAccountImageVisible = showAccountImage
            isAvatarLayoutVisible = showAvatarImage || showAccountImage
        }
        show()
    }

    private fun setupTitle(titleResId: Int?, titleColor: Int? = null) {
        if (titleResId != null) {
            binding.toolbarTitleTextView.setText(titleResId)
        } else {
            binding.toolbarTitleTextView.text = ""
        }
        if (titleColor != null) {
            binding.toolbarTitleTextView.setTextColor(ContextCompat.getColor(context, titleColor))
        }
    }

    private fun setupBackground(newBackgroundColor: Int?) {
        if (newBackgroundColor != null) {
            setBackgroundResource(newBackgroundColor)
        } else {
            background = null
        }
    }

    private fun setupCenterImage(imageRes: Int?) {
        if (imageRes != null) {
            setCenterImage(imageRes)
        } else {
            binding.toolbarCenterImageView.hide()
        }
    }

    fun configureStartButton(resId: Int?, clickAction: (() -> Unit)?, iconColor: Int? = null) {
        binding.startImageButton.apply {
            if (resId == null) {
                hide()
                return
            }
            imageTintList = iconColor?.let { ContextCompat.getColorStateList(context, iconColor) }
            setImageResource(resId)
            setOnClickListener { clickAction?.invoke() }
            show()
        }
    }

    fun changeTitle(title: String) {
        binding.toolbarTitleTextView.text = title
    }

    fun changeTitle(@StringRes titleRes: Int) {
        binding.toolbarTitleTextView.setText(titleRes)
    }

    fun changeTitle(title: CharSequence) {
        binding.toolbarTitleTextView.text = title
    }

    fun setCenterImage(@DrawableRes imageRes: Int) {
        binding.toolbarCenterImageView.apply {
            show()
            setImageResource(imageRes)
        }
    }

    fun setNodeStatus(activatedNode: Node?) {
        binding.nodeStatusTextView.text = activatedNode?.networkSlug
    }

    fun addButtonToEnd(button: BaseToolbarButton) {
        binding.buttonContainerView.addButton(button)
    }

    fun setAssetAvatar(isAlgorand: Boolean, fullName: String?) {
        val assetFullName = fullName ?: context.getString(R.string.unnamed)
        changeTitle(if (isAlgorand) ALGOS_SHORT_NAME else assetFullName)
        binding.assetAvatarView.setAssetAvatar(isAlgorand, assetFullName)
    }

    fun setAssetAvatarIfAlgo(isAlgo: Boolean, shortName: String?) {
        val assetShortName = shortName ?: context.getString(R.string.unnamed)
        changeTitle(if (isAlgo) ALGOS_SHORT_NAME else assetShortName)
        if (isAlgo) {
            isAssetAvatarVisible = isAlgo
            isAvatarLayoutVisible = isAlgo
            binding.assetAvatarView.setAssetAvatar(true, assetShortName)
        }
    }

    fun setAccountImage(accountIcon: AccountIcon) {
        binding.accountImageView.setAccountIcon(accountIcon, R.dimen.toolbar_avatar_view_padding)
    }

    private fun initRootView() {
        setBackgroundColor(ContextCompat.getColor(context, R.color.primary_background))
    }
}
