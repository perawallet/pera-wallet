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
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.isVisible
import androidx.core.view.setPadding
import androidx.core.view.updatePadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectExtrasCardBinding
import com.algorand.android.models.AssetParams
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectExtras
import com.algorand.android.utils.viewbinding.viewBinding

class WalletConnectExtrasCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectExtrasCardBinding::inflate)

    private var listener: Listener? = null

    init {
        initRootLayout()
    }

    fun initExtras(extras: WalletConnectExtras, listener: Listener) {
        this.listener = listener
        with(extras) {
            initNote(note)
            initRawTxnsText(rawTransaction)
            initAlgoExplorer(algoExplorerUrl, networkSlug)
            initAssetUrl(assetUrl)
            initAssetMetaData(assetMetadata)
        }
    }

    private fun initNote(note: String?) {
        with(binding) {
            noteTextView.text = note
            noteGroup.isVisible = !note.isNullOrBlank()
        }
    }

    private fun initRawTxnsText(rawTransaction: WCAlgoTransactionRequest) {
        binding.rawTxnsTextView.setOnClickListener { listener?.onRawTransactionClick(rawTransaction) }
    }

    private fun initAlgoExplorer(algoExplorerUrl: String?, networkSlug: String?) {
        with(binding) {
            algoExplorerGroup.isVisible = algoExplorerUrl.isNullOrEmpty().not()
            algoExplorerTextView.setOnClickListener { listener?.onAlgoExplorerClick(algoExplorerUrl, networkSlug) }
        }
    }

    private fun initAssetUrl(assetUrl: String?) {
        with(binding) {
            assetUrlGroup.isVisible = assetUrl.isNullOrEmpty().not()
            assetUrlTextView.setOnClickListener { listener?.onAssetUrlClick(assetUrl) }
        }
    }

    private fun initAssetMetaData(assetParams: AssetParams?) {
        with(binding) {
            assetMetadataGroup.isVisible = assetParams != null
            assetMetadataTextView.setOnClickListener { listener?.onAssetMetadataClick(assetParams) }
        }
    }

    private fun initRootLayout() {
        setBackgroundResource(R.drawable.bg_small_shadow)
        setPadding(resources.getDimensionPixelSize(R.dimen.keyline_1_plus_4_dp))
        updatePadding(bottom = resources.getDimensionPixelSize(R.dimen.smallshadow_bottom_padding_18dp))
    }

    interface Listener {
        fun onRawTransactionClick(rawTransaction: WCAlgoTransactionRequest) {}
        fun onAlgoExplorerClick(algoExplorerId: String?, networkSlug: String?) {}
        fun onAssetUrlClick(assetUrl: String?) {}
        fun onAssetMetadataClick(assetParams: AssetParams?) {}
    }
}
