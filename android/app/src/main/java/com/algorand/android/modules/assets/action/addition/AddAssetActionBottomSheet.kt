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

package com.algorand.android.modules.assets.action.addition

import android.widget.TextView
import androidx.fragment.app.viewModels
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.models.AccountIconResource.Companion.DEFAULT_ACCOUNT_ICON_RESOURCE
import com.algorand.android.models.AssetActionResult
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.assets.action.base.BaseAssetActionBottomSheet
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.setFragmentNavigationResult
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AddAssetActionBottomSheet : BaseAssetActionBottomSheet() {

    private val toolbarConfiguration = ToolbarConfiguration(titleResId = R.string.add_new_asset)

    override val assetActionViewModel: AddAssetActionViewModel by viewModels()

    override fun initUi() {
        with(binding) {
            transactionFeeGroup.show()
            accountGroup.show()
        }
    }

    override fun setDescriptionTextView(textView: TextView) {
        textView.setText(R.string.adding_an_asset)
    }

    override fun setToolbar(customToolbar: CustomToolbar) {
        customToolbar.configure(toolbarConfiguration)
    }

    override fun setPositiveButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.approve)
            setOnClickListener {
                asset?.let { assetDescription ->
                    val assetActionResult = AssetActionResult(
                        asset = assetDescription,
                        publicKey = assetActionViewModel.accountAddress
                    )
                    (activity as? MainActivity)?.signAddAssetTransaction(assetActionResult)
                    setFragmentNavigationResult(ADD_ASSET_ACTION_RESULT_KEY, true)
                }
                navBack()
            }
        }
    }

    override fun setNegativeButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.close)
            setOnClickListener { navBack() }
        }
    }

    override fun setTransactionFeeTextView(textView: TextView) {
        textView.text = assetActionViewModel.getTransactionFee()
    }

    override fun setAccountNameTextView(textView: TextView) {
        textView.apply {
            with(assetActionViewModel.getAccountName()) {
                text = getDisplayAddress()
                setDrawable(
                    start = AccountIconDrawable.create(
                        context = context,
                        accountIconResource = accountIconResource ?: DEFAULT_ACCOUNT_ICON_RESOURCE,
                        size = resources.getDimension(R.dimen.account_icon_size_normal).toInt()
                    )
                )
                setOnLongClickListener { onAccountAddressCopied(publicKey); true }
            }
        }
    }

    companion object {
        const val ADD_ASSET_ACTION_RESULT_KEY = "add_asset_action_result_key"
    }
}
