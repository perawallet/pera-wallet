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

package com.algorand.android.modules.swap.assetselection.fromasset.ui

import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.customviews.toolbar.CustomToolbar
import com.algorand.android.modules.swap.assetselection.base.BaseSwapAssetSelectionFragment
import com.algorand.android.modules.swap.assetselection.base.BaseSwapAssetSelectionViewModel
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapAssetSelectionItem
import com.algorand.android.utils.setFragmentNavigationResult
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SwapFromAssetSelectionFragment : BaseSwapAssetSelectionFragment() {

    private val swapFromAssetSelectionViewModel by viewModels<SwapFromAssetSelectionViewModel>()

    override val baseAssetSelectionViewModel: BaseSwapAssetSelectionViewModel
        get() = swapFromAssetSelectionViewModel

    override fun onAssetSelected(assetItem: SwapAssetSelectionItem) {
        setFragmentNavigationResult(SWAP_FROM_ASSET_ID_KEY, assetItem.assetId)
        navBack()
    }

    override fun setToolbarTitle(toolbar: CustomToolbar?) {
        toolbar?.changeTitle(R.string.swap_from)
    }

    companion object {
        const val SWAP_FROM_ASSET_ID_KEY = "swapFromAssetIdKey"
    }
}
