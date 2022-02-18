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

package com.algorand.android.ui.assetaction

import android.widget.TextView
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseAssetActionBottomSheet
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.models.AssetActionResult
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.setNavigationResult
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class TransferBalanceActionBottomSheet : BaseAssetActionBottomSheet() {

    override val accountName: String by lazy { args.assetAction.publicKey.orEmpty() }
    override val assetId: Long by lazy { args.assetAction.assetId }

    private val args: TransferBalanceActionBottomSheetArgs by navArgs()

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_close,
        titleResId = R.string.remove_assets
    )

    override fun initArgs() {
        this@TransferBalanceActionBottomSheet.asset = args.assetAction.asset
            ?: assetActionViewModel.getAssetDescription(assetId)
    }

    override fun setDescriptionTextView(textView: TextView) {
        textView.text = context?.getXmlStyledString(
            stringResId = R.string.to_remove_the_balance,
            replacementList = listOf("asset_name" to asset?.fullName.orEmpty())
        )
    }

    override fun setToolbar(customToolbar: CustomToolbar) {
        customToolbar.configure(toolbarConfiguration)
    }

    override fun setPositiveButton(materialButton: MaterialButton) {
        materialButton.setText(R.string.transfer_balance)
        materialButton.setOnClickListener {
            asset?.let { assetDescription ->
                val assetActionResult = AssetActionResult(
                    assetDescription,
                    args.assetAction.publicKey
                )
                setNavigationResult(TRANSFER_ASSET_ACTION_RESULT, assetActionResult)
            }
            navBack()
        }
    }

    override fun setNegativeButton(materialButton: MaterialButton) {
        materialButton.setText(R.string.cancel)
        materialButton.setOnClickListener {
            navBack()
        }
    }

    companion object {
        const val TRANSFER_ASSET_ACTION_RESULT = "transfer_asset_action_result"
    }
}
