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

package com.algorand.android.modules.assets.action.optin

import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.algorand.android.customviews.toolbar.CustomToolbar
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetOperationResult
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.assets.action.base.BaseAssetActionBottomSheet
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.setNavigationResult
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class OptInAssetActionBottomSheet : BaseAssetActionBottomSheet() {

    private val toolbarConfiguration = ToolbarConfiguration(titleResId = R.string.your_accounts_don_t)

    override val assetActionViewModel by viewModels<OptInAssetActionViewModel>()

    override fun setDescriptionTextView(textView: TextView) {
        textView.apply {
            text = getString(R.string.your_accounts_don_t_contain_this)
            setTextColor(ContextCompat.getColor(context, R.color.negative))
        }
    }

    override fun setWarningIconImageView(imageView: ImageView) {
        imageView.show()
    }

    override fun setToolbar(customToolbar: CustomToolbar) {
        customToolbar.configure(toolbarConfiguration)
    }

    override fun setPositiveButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.opt_dash_in)
            setOnClickListener { handleAssetAddition(assetActionViewModel.assetAction) }
        }
    }

    override fun setNegativeButton(materialButton: MaterialButton) {
        materialButton.hide()
    }

    private fun handleAssetAddition(assetAction: AssetAction) {
        nav(
            OptInAssetActionBottomSheetDirections
                .actionOptInAssetActionBottomSheetToAssetAdditionActionNavigation(
                    assetAction = assetAction,
                    shouldWaitForConfirmation = true
                )
        )
        (activity as? MainActivity)?.mainViewModel?.assetOperationResultLiveData?.observe(viewLifecycleOwner) {
            it.peek().use(
                onSuccess = {
                    if (it is AssetOperationResult.AssetAdditionOperationResult && it.assetId == assetAction.assetId) {
                        assetAction.publicKey?.run {
                            setNavigationResult(OPT_IN_RESULT_SUCCESSFUL_KEY, Pair(true, this))
                            navBack()
                        }
                    }
                }
            )
        }
    }

    companion object {
        const val OPT_IN_RESULT_SUCCESSFUL_KEY = "opt_in_result_successful_key"
    }
}
