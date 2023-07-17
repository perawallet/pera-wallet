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
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.net.toUri
import androidx.core.view.isInvisible
import androidx.core.view.isVisible
import androidx.lifecycle.findViewTreeLifecycleOwner
import com.algorand.android.R
import com.algorand.android.databinding.CustomUserViewBinding
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.TooltipConfig
import com.algorand.android.models.User
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.enableLongPressToCopyText
import com.algorand.android.utils.extensions.changeTextAppearance
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.setContactIconDrawable
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.loadImage
import com.algorand.android.utils.viewbinding.viewBinding

class AlgorandUserView @JvmOverloads constructor(
    context: Context,
    val attrs: AttributeSet? = null,
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomUserViewBinding::inflate)
    private var onAddButtonClick: ((String) -> Unit?)? = null

    fun setContact(user: User, enableAddressCopy: Boolean = true, showTooltip: Boolean = false) {
        with(binding) {
            mainTextView.apply {
                maxLines = MAX_LINES_FOR_CONTACT
                text = user.name
                changeTextAppearance(R.style.TextAppearance_Body_Sans)
            }
            accountIconImageView.apply {
                setContactIconDrawable(
                    uri = user.imageUriAsString?.toUri(),
                    iconSize = R.dimen.account_icon_size_normal
                )
                show()
            }
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
                maxLines = MAX_LINES_FOR_CONTACT
                text = name
                changeTextAppearance(R.style.TextAppearance_Body_Sans)
            }
            accountIconImageView.apply {
                setContactIconDrawable(
                    uri = imageUriAsString,
                    iconSize = R.dimen.account_icon_size_normal
                )
                show()
            }
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
                maxLines = MAX_LINES_FOR_ADDRESS
                text = displayAddress
                changeTextAppearance(R.style.TextAppearance_Body_Mono)
            }
            addContactButton.apply {
                setOnClickListener { onAddButtonClick?.invoke(publicKey) }
                isVisible = showAddButton
            }
            val accountIconDrawable = AccountIconDrawable.create(
                context = context,
                sizeResId = R.dimen.spacing_xlarge,
                accountIconDrawablePreview = AccountIconDrawablePreview(
                    backgroundColorResId = R.color.wallet_placeholder,
                    iconTintResId = R.color.wallet_placeholder_icon,
                    iconResId = R.drawable.ic_wallet
                )
            )
            accountIconImageView.setImageDrawable(accountIconDrawable)
        }
        if (enableAddressCopy) enableLongPressToCopyText(publicKey)
        if (showTooltip) showCopyTutorial()
    }

    fun setNftDomainAddress(nftDomainAddress: String, nftDomainServiceLogoUrl: String?) {
        with(binding) {
            mainTextView.apply {
                text = nftDomainAddress
                maxLines = MAX_LINES_FOR_NFT_DOMAIN
            }
            accountIconImageView.apply {
                context.loadImage(
                    nftDomainServiceLogoUrl.orEmpty(),
                    onResourceReady = { setImageDrawable(it) },
                    onLoadFailed = { setImageResource(R.drawable.ic_nfd_round) }
                )
                show()
            }
        }
    }

    fun setAccount(
        accountCacheData: AccountCacheData?,
        accountIconDrawablePreview: AccountIconDrawablePreview?,
        enableAddressCopy: Boolean = true
    ) {
        with(binding) {
            mainTextView.apply {
                maxLines = MAX_LINES_FOR_ACCOUNT
                text = accountCacheData?.account?.name
                changeTextAppearance(R.style.TextAppearance_Body_Sans)
            }
            if (accountCacheData?.account != null) {
                if (accountIconDrawablePreview != null) {
                    val accountIconDrawable = AccountIconDrawable.create(
                        context,
                        accountIconDrawablePreview = accountIconDrawablePreview,
                        sizeResId = R.dimen.spacing_xlarge
                    )
                    accountIconImageView.apply {
                        setImageDrawable(accountIconDrawable)
                        show()
                    }
                }
                if (enableAddressCopy) enableLongPressToCopyText(accountCacheData.account.address)
            }
            addContactButton.hide()
        }
    }

    fun setAccount(
        name: String,
        accountIconDrawablePreview: AccountIconDrawablePreview?,
        publicKey: String,
        enableAddressCopy: Boolean = true,
        showTooltip: Boolean = false
    ) {
        with(binding) {
            mainTextView.apply {
                maxLines = MAX_LINES_FOR_ACCOUNT
                text = name
                changeTextAppearance(R.style.TextAppearance_Body_Sans)
            }
            accountIconDrawablePreview?.let {
                val accountIconDrawable = AccountIconDrawable.create(
                    context = context,
                    accountIconDrawablePreview = it,
                    sizeResId = R.dimen.spacing_xlarge
                )
                accountIconImageView.setImageDrawable(accountIconDrawable)
                accountIconImageView.show()
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
        with(binding.mainTextView) {
            postDelayed({
                val margin = resources.getDimensionPixelOffset(R.dimen.spacing_xlarge)
                val config = TooltipConfig(
                    anchor = this,
                    offsetX = margin,
                    tooltipTextResId = R.string.press_and_hold
                )
                Tooltip(context).show(config, findViewTreeLifecycleOwner())
            }, TUTORIAL_SHOW_DELAY)
        }
    }

    companion object {
        private const val TUTORIAL_SHOW_DELAY = 600L
        private const val MAX_LINES_FOR_CONTACT = 1
        private const val MAX_LINES_FOR_ACCOUNT = 1
        private const val MAX_LINES_FOR_NFT_DOMAIN = 1
        private const val MAX_LINES_FOR_ADDRESS = Int.MAX_VALUE
    }
}
