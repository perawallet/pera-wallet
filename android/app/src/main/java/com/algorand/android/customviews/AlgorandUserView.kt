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
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.net.toUri
import androidx.core.view.isInvisible
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.CustomUserViewBinding
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AccountIcon
import com.algorand.android.models.User
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.extensions.changeTextAppearance
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.viewbinding.viewBinding

class AlgorandUserView @JvmOverloads constructor(
    context: Context,
    val attrs: AttributeSet? = null,
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomUserViewBinding::inflate)
    private var onAddButtonClick: ((String) -> Unit?)? = null

    fun setContact(user: User, enableAddressCopy: Boolean = true) {
        with(binding) {
            mainTextView.apply {
                text = user.name
                changeTextAppearance(R.style.TextAppearance_Body_Sans)
            }
            accountIconImageView.loadAccountImage(
                uri = user.imageUriAsString?.toUri(),
                padding = R.dimen.spacing_xxsmall
            )
            addButton.hide()
        }
        if (enableAddressCopy) {
            setLongPressToCopy(user.publicKey)
        }
    }

    fun setAddress(address: String, enableAddressCopy: Boolean = true, showAddButton: Boolean = true) {
        with(binding) {
            mainTextView.apply {
                text = address.toShortenedAddress()
                changeTextAppearance(R.style.TextAppearance_Body_Mono)
            }
            addButton.apply {
                setOnClickListener { onAddButtonClick?.invoke(address) }
                isVisible = showAddButton
            }
            accountIconImageView.hide()
        }
        if (enableAddressCopy) {
            setLongPressToCopy(address)
        }
    }

    fun setAccount(accountCacheData: AccountCacheData?) {
        with(binding) {
            mainTextView.apply {
                text = accountCacheData?.account?.name
                changeTextAppearance(R.style.TextAppearance_Body_Sans)
            }
            accountCacheData?.account?.let {
                accountIconImageView.setAccountIcon(it.createAccountIcon(), R.dimen.spacing_xxsmall)
            }
            addButton.hide()
        }
    }

    fun setAccount(name: String, icon: AccountIcon) {
        with(binding) {
            mainTextView.apply {
                text = name
                changeTextAppearance(R.style.TextAppearance_Body_Sans)
            }
            accountIconImageView.setAccountIcon(icon, R.dimen.spacing_xxsmall)
            addButton.hide()
        }
    }

    fun setOnAddButtonClickListener(onAddButtonClick: (String) -> Unit) {
        if (binding.addButton.isInvisible) return
        this.onAddButtonClick = onAddButtonClick
    }

    private fun setLongPressToCopy(address: String) {
        binding.mainTextView.setOnLongClickListener {
            context.copyToClipboard(address)
            return@setOnLongClickListener true
        }
    }
}
