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

package com.algorand.android.modules.assets.action.transferbalance

import android.widget.TextView
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.customviews.toolbar.CustomToolbar
import com.algorand.android.models.AssetActionResult
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.assets.action.base.BaseAssetActionBottomSheet
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.setFragmentNavigationResult
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class TransferBalanceActionBottomSheet : BaseAssetActionBottomSheet() {

    private val toolbarConfiguration = ToolbarConfiguration(titleResId = R.string.remove_assets)

    override fun initUi() {
        binding.accountGroup.show()
    }

    override val assetActionViewModel by viewModels<TransferBalanceActionViewModel>()

    override fun setDescriptionTextView(textView: TextView) {
        textView.text = context?.getXmlStyledString(
            stringResId = R.string.to_opt_out_and_remove,
            replacementList = listOf("asset_name" to assetActionViewModel.assetFullName.getName(resources))
        )
    }

    override fun setToolbar(customToolbar: CustomToolbar) {
        customToolbar.configure(toolbarConfiguration)
    }

    override fun setPositiveButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.transfer_balance)
            setOnClickListener {
                asset?.let { assetDescription ->
                    val assetActionResult = AssetActionResult(
                        asset = assetDescription,
                        publicKey = assetActionViewModel.accountAddress
                    )
                    setFragmentNavigationResult(key = TRANSFER_ASSET_ACTION_RESULT, value = assetActionResult)
                }
                dismissAllowingStateLoss()
            }
        }
    }

    override fun setNegativeButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.cancel)
            setOnClickListener { navBack() }
        }
    }

    override fun setAccountNameTextView(textView: TextView) {
        textView.apply {
            with(assetActionViewModel.getAccountName()) {
                text = getDisplayAddress()
                setDrawable(
                    start = AccountIconDrawable.create(
                        context = context,
                        accountIconDrawablePreview = accountIconDrawablePreview,
                        sizeResId = R.dimen.spacing_xlarge
                    )
                )
                setOnLongClickListener { onAccountAddressCopied(publicKey); true }
            }
        }
    }

    companion object {
        const val TRANSFER_ASSET_ACTION_RESULT = "transfer_asset_action_result"
    }
}
