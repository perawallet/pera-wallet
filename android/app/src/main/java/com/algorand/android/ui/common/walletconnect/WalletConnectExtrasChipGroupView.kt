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
import androidx.annotation.DimenRes
import androidx.annotation.StringRes
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.models.AssetParams
import com.algorand.android.models.TransactionRequestExtrasInfo
import com.algorand.android.models.WCAlgoTransactionRequest
import com.google.android.material.chip.Chip
import com.google.android.material.chip.ChipGroup
import com.google.android.material.resources.TextAppearance

class WalletConnectExtrasChipGroupView(
    context: Context,
    attrs: AttributeSet? = null
) : ChipGroup(context, attrs) {

    private var listener: Listener? = null

    fun setChipGroupListener(listener: Listener) {
        this.listener = listener
    }

    fun initExtrasButtons(
        transactionRequestExtrasInfo: TransactionRequestExtrasInfo,
        @DimenRes padding: Int
    ) {
        updatePadding(padding)
        with(transactionRequestExtrasInfo) {
            createRawTransactionChip(rawTransaction)
            createShowAssetInAlgoExplorerChip(assetId)
            createShowAppInAlgoExplorerChip(appId)
            createAssetUrlChip(assetUrl)
            createAssetMetadataChip(assetMetadata)
        }
    }

    fun initOpenInExplorerChips(transactionIdWithoutPrefix: String?, @DimenRes padding: Int) {
        updatePadding(padding)
        transactionIdWithoutPrefix?.let {
            createOpenInAlgoExplorerChip(it)
            createOpenInGoalSeekerChip(it)
        }
    }

    private fun createRawTransactionChip(rawTransaction: WCAlgoTransactionRequest) {
        Chip(context).apply {
            val rawTransactionChip = createChip(R.string.raw_transaction)
            rawTransactionChip.setOnClickListener { listener?.onRawTransactionClick(rawTransaction) }
            addView(rawTransactionChip)
        }
    }

    private fun createShowAssetInAlgoExplorerChip(assetId: Long?) {
        if (assetId != null) {
            val showAssetInAlgoExplorerChip = createChip(R.string.show_algoexplorer)
            showAssetInAlgoExplorerChip.setOnClickListener { listener?.onShowAssetInAlgoExplorerClick(assetId) }
            addView(showAssetInAlgoExplorerChip)
        }
    }

    private fun createShowAppInAlgoExplorerChip(appId: Long?) {
        if (appId != null) {
            val showAlgoAppInExplorerChip = createChip(R.string.show_algoexplorer)
            showAlgoAppInExplorerChip.setOnClickListener { listener?.onShowAppInAlgoExplorerClick(appId) }
            addView(showAlgoAppInExplorerChip)
        }
    }

    private fun createAssetUrlChip(url: String?) {
        if (url != null) {
            val assetUrlChip = createChip(R.string.show_asset_url)
            assetUrlChip.setOnClickListener { listener?.onAssetUrlClick(url) }
            addView(assetUrlChip)
        }
    }

    private fun createAssetMetadataChip(assetParams: AssetParams?) {
        if (assetParams != null) {
            val assetMetadataChip = createChip(R.string.show_asset_metadata)
            assetMetadataChip.setOnClickListener { listener?.onAssetMetadataClick(assetParams) }
            addView(assetMetadataChip)
        }
    }

    private fun createChip(@StringRes textRes: Int): Chip {
        return Chip(context).apply {
            text = context?.getString(textRes)
            setTextAppearance(TextAppearance(context, R.style.TextAppearance_Footnote_Sans_Medium))
            setChipBackgroundColorResource(R.color.layerGrayLighter)
        }
    }

    private fun createOpenInAlgoExplorerChip(url: String) {
        val showInAlgoExplorerChip = createChip(R.string.open_in_algoexplorer)
        showInAlgoExplorerChip.setOnClickListener { listener?.onOpenInAlgoExplorerClick(url) }
        addView(showInAlgoExplorerChip)
    }

    private fun createOpenInGoalSeekerChip(url: String) {
        val showInGoalSeekerChip = createChip(R.string.open_in_goalseeker)
        showInGoalSeekerChip.setOnClickListener { listener?.onOpenInGoalSeekerClick(url) }
        addView(showInGoalSeekerChip)
    }

    private fun updatePadding(@DimenRes padding: Int) {
        setPadding(resources.getDimensionPixelSize(padding))
    }

    interface Listener {
        fun onRawTransactionClick(rawTransaction: WCAlgoTransactionRequest) {}
        fun onShowAssetInAlgoExplorerClick(assetId: Long) {}
        fun onShowAppInAlgoExplorerClick(appId: Long) {}
        fun onAssetUrlClick(url: String) {}
        fun onAssetMetadataClick(assetParams: AssetParams) {}

        fun onOpenInAlgoExplorerClick(url: String) {}
        fun onOpenInGoalSeekerClick(url: String) {}
    }
}
