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

import android.content.Context
import android.widget.TextView
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.models.AssetActionResult
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.assets.action.base.BaseAssetActionBottomSheet
import com.algorand.android.utils.getXmlStyledString
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class UnsupportedAssetNotificationRequestActionBottomSheet : BaseAssetActionBottomSheet() {

    private val toolbarConfiguration = ToolbarConfiguration(titleResId = R.string.you_are_about_to_receive)

    private var listener: RequestAssetConfirmationListener? = null

    override val assetActionViewModel by viewModels<UnsupportedAssetNotificationRequestActionViewModel>()

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = activity as? RequestAssetConfirmationListener
    }

    override fun setDescriptionTextView(textView: TextView) {
        textView.text = context?.getXmlStyledString(
            stringResId = R.string.you_are_about_to_receive_description,
            replacementList = listOf("account_name" to assetActionViewModel.accountAddress)
        )
    }

    override fun setToolbar(customToolbar: CustomToolbar) {
        customToolbar.configure(toolbarConfiguration)
    }

    override fun setPositiveButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.ok)
            setOnClickListener {
                asset?.let { assetDescription ->
                    val assetActionResult = AssetActionResult(
                        asset = assetDescription,
                        publicKey = assetActionViewModel.accountAddress
                    )
                    listener?.onUnsupportedAssetRequest(assetActionResult)
                }
                navBack()
            }
        }
    }

    override fun setNegativeButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.cancel)
            setOnClickListener { navBack() }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        listener = null
    }

    interface RequestAssetConfirmationListener {
        fun onUnsupportedAssetRequest(assetActionResult: AssetActionResult)
    }
}
