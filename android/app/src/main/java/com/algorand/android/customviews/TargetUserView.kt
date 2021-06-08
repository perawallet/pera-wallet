/*
 * Copyright 2019 Algorand, Inc.
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
import androidx.core.net.toUri
import com.algorand.android.R
import com.algorand.android.databinding.CustomTargetUserBinding
import com.algorand.android.models.User
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.loadContactProfileImage
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.viewbinding.viewBinding

// TODO create target user and use it everywhere.
class TargetUserView @JvmOverloads constructor(
    context: Context,
    val attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : ConstraintLayout(context, attrs, defStyleAttr) {

    private var listener: Listener? = null

    private val binding = viewBinding(CustomTargetUserBinding::inflate)

    fun setUser(
        user: User,
        showAction: Boolean = true,
        enableAddressCopy: Boolean = false,
        shouldUsePlaceHolder: Boolean = true
    ) {
        binding.userImageView.apply {
            loadContactProfileImage(user.imageUriAsString?.toUri(), shouldUsePlaceHolder = shouldUsePlaceHolder)
            visibility = View.VISIBLE
        }

        binding.mainTextView.text = user.name

        if (showAction) {
            binding.actionButton.apply {
                visibility = View.VISIBLE
                setIconResource(R.drawable.ic_show_qr)
                setOnClickListener { listener?.onShowQrClick(user) }
            }
        } else {
            binding.actionButton.visibility = View.GONE
        }

        if (enableAddressCopy) {
            setLongPressToCopy(user.publicKey)
        }
    }

    fun setAddress(
        address: String,
        showAction: Boolean = true,
        showShortened: Boolean = true,
        enableAddressCopy: Boolean = false
    ) {
        binding.userImageView.visibility = View.GONE
        binding.mainTextView.text = if (showShortened) address.toShortenedAddress() else address

        if (showAction) {
            binding.actionButton.apply {
                visibility = View.VISIBLE
                setIconResource(R.drawable.ic_user_add)
                setOnClickListener { listener?.onAddContactClick(address) }
            }
        } else {
            binding.actionButton.visibility = View.GONE
        }

        if (enableAddressCopy) {
            setLongPressToCopy(address)
        }
    }

    private fun setLongPressToCopy(address: String) {
        binding.mainTextView.setOnLongClickListener {
            context.copyToClipboard(address)
            return@setOnLongClickListener true
        }
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    interface Listener {
        fun onShowQrClick(user: User)
        fun onAddContactClick(address: String)
    }
}
