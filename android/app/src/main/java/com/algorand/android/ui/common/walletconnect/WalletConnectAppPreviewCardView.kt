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

package com.algorand.android.ui.common.walletconnect

import android.content.Context
import android.util.AttributeSet
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import com.algorand.android.databinding.CustomWalletConnectAppPreviewViewBinding
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.utils.loadPeerMetaIcon
import com.algorand.android.utils.viewbinding.viewBinding

class WalletConnectAppPreviewCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectAppPreviewViewBinding::inflate)

    fun initPeerMeta(peerMeta: WalletConnectPeerMeta, message: String?, listener: OnShowMoreClickListener) {
        with(peerMeta) {
            with(binding) {
                dAppIconImageView.loadPeerMetaIcon(icons.firstOrNull())
                dAppNameTextView.text = name
                initMessagePreview(peerMeta, message, listener)
            }
        }
    }

    private fun initMessagePreview(
        peerMeta: WalletConnectPeerMeta,
        message: String?,
        listener: OnShowMoreClickListener
    ) {
        with(binding) {
            val message = message.orEmpty()
            val isMessageValid = message.isNotEmpty()

            dAppMessagePreviewTextView.apply {
                text = message
                isVisible = isMessageValid
            }

            showMoreInfoTextView.apply {
                isVisible = isMessageValid
                setOnClickListener { listener.onClick(peerMeta, message) }
            }
        }
    }

    fun interface OnShowMoreClickListener {
        fun onClick(peerMeta: WalletConnectPeerMeta, description: String)
    }
}
