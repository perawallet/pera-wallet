/*
 * Copyright 2019 Algorand, Inc.
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
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.view.setPadding
import androidx.core.view.updatePadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectAppPreviewViewBinding
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.utils.loadPeerMetaIcon
import com.algorand.android.utils.viewbinding.viewBinding

class WalletConnectAppPreviewCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectAppPreviewViewBinding::inflate)

    init {
        initRootLayout()
    }

    fun initPeerMeta(peerMeta: WalletConnectPeerMeta, message: String?, listener: OnShowMoreClickListener) {
        with(peerMeta) {
            with(binding) {
                appIconImageView.loadPeerMetaIcon(icons.firstOrNull())
                appNameTextView.text = name
                if (message.isNullOrBlank()) {
                    centerTitleTextViewVertically()
                } else {
                    initMessagePreview(peerMeta, message, listener)
                }
            }
        }
    }

    private fun initMessagePreview(
        peerMeta: WalletConnectPeerMeta,
        message: String?,
        listener: OnShowMoreClickListener
    ) {
        with(binding) {
            appMessagePreviewTextView.apply {
                text = message.orEmpty()
                visibility = View.VISIBLE
            }
            if (!message.isNullOrBlank()) {
                showMoreInfoTextView.apply {
                    visibility = View.VISIBLE
                    setOnClickListener { listener.onClick(peerMeta, message) }
                }
            }
        }
    }

    private fun centerTitleTextViewVertically() {
        ConstraintSet().apply {
            clone(this@WalletConnectAppPreviewCardView)
            connect(R.id.appNameTextView, ConstraintSet.BOTTOM, R.id.appIconImageView, ConstraintSet.BOTTOM)
            applyTo(this@WalletConnectAppPreviewCardView)
        }
    }

    private fun initRootLayout() {
        setBackgroundResource(R.drawable.bg_small_shadow)
        setPadding(resources.getDimensionPixelSize(R.dimen.keyline_1_plus_4_dp))
        updatePadding(bottom = resources.getDimensionPixelSize(R.dimen.smallshadow_bottom_padding_18dp))
    }

    fun interface OnShowMoreClickListener {
        fun onClick(peerMeta: WalletConnectPeerMeta, description: String)
    }
}
