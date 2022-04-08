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

package com.algorand.android.nft.ui.nfsdetail

import android.widget.TextView
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseAssetActionBottomSheet
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.utils.setNavigationResult
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class CollectibleOptOutConfirmationBottomSheet : BaseAssetActionBottomSheet() {

    private val args by navArgs<CollectibleOptOutConfirmationBottomSheetArgs>()

    override val accountName: String by lazy { args.accountName }

    override val assetId: Long by lazy { args.collectibleAssetId }

    override fun initArgs() {
        assetActionViewModel.fetchAssetDescription(assetId)
    }

    override fun setDescriptionTextView(textView: TextView) {
        textView.text = getString(R.string.you_are_about_to_opt_out, accountName)
    }

    override fun setToolbar(customToolbar: CustomToolbar) {
        customToolbar.changeTitle(getString(R.string.opt_out_from, args.collectibleName ?: assetId.toString()))
    }

    override fun setPositiveButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.opt_out)
            setOnClickListener {
                setNavigationResult(COLLECTIBLE_OPT_OUT_KEY, true)
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

    companion object {
        const val COLLECTIBLE_OPT_OUT_KEY = "collectible_opt_out_key"
    }
}
