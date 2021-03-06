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

package com.algorand.android.customviews

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.net.toUri
import androidx.core.view.isInvisible
import androidx.core.view.isVisible
import androidx.lifecycle.findViewTreeLifecycleOwner
import com.algorand.android.R
import com.algorand.android.databinding.CustomUserViewBinding
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AccountIcon
import com.algorand.android.models.TooltipConfig
import com.algorand.android.models.User
import com.algorand.android.utils.enableLongPressToCopyText
import com.algorand.android.utils.extensions.changeTextAppearance
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.viewbinding.viewBinding

class AlgorandUserView @JvmOverloads constructor(
    context: Context,
    val attrs: AttributeSet? = null,
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomUserViewBinding::inflate)
    private var onAddButtonClick: ((String) -> Unit?)? = null
    private var tutorialShowHandler: Handler? = null

    fun setContact(user: User, enableAddressCopy: Boolean = true, showTooltip: Boolean = false) {
        with(binding) {
            mainTextView.apply {
                text = user.name
                changeTextAppearance(R.style.TextAppearance_Body_Sans)
            }
            accountIconImageView.loadAccountImage(
                uri = user.imageUriAsString?.toUri(),
                padding = R.dimen.spacing_xxsmall
            )
            addContactButton.hide()
        }
        if (enableAddressCopy) enableLongPressToCopyText(user.publicKey)
        if (showTooltip) showCopyTutorial()
    }

    fun setContact(
        name: String,
        imageUriAsString: Uri?,
        publicKey: String,
        enableAddressCopy: Boolean = true,
        showTooltip: Boolean = false
    ) {
        with(binding) {
            mainTextView.apply {
                text = name
                changeTextAppearance(R.style.TextAppearance_Body_Sans)
            }
            accountIconImageView.loadAccountImage(
                uri = imageUriAsString,
                padding = R.dimen.spacing_xxsmall
            )
            addContactButton.hide()
        }
        if (enableAddressCopy) enableLongPressToCopyText(publicKey)
        if (showTooltip) showCopyTutorial()
    }

    fun setAddress(
        displayAddress: String,
        publicKey: String,
        enableAddressCopy: Boolean = true,
        showAddButton: Boolean = true,
        showTooltip: Boolean = false
    ) {
        with(binding) {
            mainTextView.apply {
                text = displayAddress
                changeTextAppearance(R.style.TextAppearance_Body_Mono)
            }
            addContactButton.apply {
                setOnClickListener { onAddButtonClick?.invoke(publicKey) }
                isVisible = showAddButton
            }
            accountIconImageView.hide()
        }
        if (enableAddressCopy) enableLongPressToCopyText(publicKey)
        if (showTooltip) showCopyTutorial()
    }

    fun setAccount(accountCacheData: AccountCacheData?, enableAddressCopy: Boolean = true) {
        with(binding) {
            mainTextView.apply {
                text = accountCacheData?.account?.name
                changeTextAppearance(R.style.TextAppearance_Body_Sans)
            }
            if (accountCacheData?.account != null) {
                accountIconImageView.setAccountIcon(
                    accountIcon = accountCacheData.account.createAccountIcon(),
                    padding = R.dimen.spacing_xxsmall
                )
                if (enableAddressCopy) enableLongPressToCopyText(accountCacheData.account.address)
            }
            addContactButton.hide()
        }
    }

    fun setAccount(
        name: String,
        icon: AccountIcon?,
        publicKey: String,
        enableAddressCopy: Boolean = true,
        showTooltip: Boolean = false
    ) {
        with(binding) {
            mainTextView.apply {
                text = name
                changeTextAppearance(R.style.TextAppearance_Body_Sans)
            }
            icon?.let {
                accountIconImageView.setAccountIcon(it, R.dimen.spacing_xxsmall)
            } ?: accountIconImageView.hide()
            addContactButton.hide()
            if (enableAddressCopy) enableLongPressToCopyText(publicKey)
        }
        if (showTooltip) showCopyTutorial()
    }

    fun setOnAddButtonClickListener(onAddButtonClick: (String) -> Unit) {
        if (binding.addContactButton.isInvisible) return
        this.onAddButtonClick = onAddButtonClick
    }

    private fun showCopyTutorial() {
        tutorialShowHandler = Handler()
        tutorialShowHandler?.postDelayed({
            binding.mainTextView.run {
                val margin = resources.getDimensionPixelOffset(R.dimen.spacing_xlarge)
                val config = TooltipConfig(
                    anchor = this,
                    offsetX = margin,
                    tooltipTextResId = R.string.press_and_hold
                )
                Tooltip(context).show(config, findViewTreeLifecycleOwner())
            }
        }, TUTORIAL_SHOW_DELAY)
    }

    companion object {
        private const val TUTORIAL_SHOW_DELAY = 600L
    }
}
