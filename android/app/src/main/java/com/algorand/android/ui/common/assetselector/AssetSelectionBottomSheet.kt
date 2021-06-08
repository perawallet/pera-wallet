/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.common.assetselector

import android.os.Bundle
import android.os.Parcelable
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.HomeNavigationDirections.Companion.actionGlobalSendInfoFragment
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetAssetSelectionBinding
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.common.assetselector.AssetSelectionBottomSheetDirections.Companion.actionAssetSelectionBottomSheetToShowQrBottomSheet
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.parcelize.Parcelize

@AndroidEntryPoint
class AssetSelectionBottomSheet : DaggerBaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_asset_selection,
    fullPageNeeded = true,
    firebaseEventScreenId = null
) {

    private val assetSelectionViewModel: AssetSelectionViewModel by viewModels()

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.select_asset,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    private val args: AssetSelectionBottomSheetArgs by navArgs()

    private val binding by viewBinding(BottomSheetAssetSelectionBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.toolbar.configure(toolbarConfiguration)
        setupRecyclerView()
    }

    private fun setupRecyclerView() {
        val assetSelectionList = assetSelectionViewModel.getAssetSelectionList(args.selectedAssetInformation)
        binding.assetRecyclerView.adapter = AssetSelectorAdapter(assetSelectionList, ::onAssetClick)
        binding.emptyStateTextView.isVisible = assetSelectionList.isEmpty()
    }

    private fun onAssetClick(accountCacheData: AccountCacheData, assetInformation: AssetInformation) {
        when (args.flowType) {
            FlowType.REQUEST -> {
                with(accountCacheData.account) {
                    nav(actionAssetSelectionBottomSheetToShowQrBottomSheet(title = name, qrText = address))
                }
            }
            FlowType.SEND -> {
                nav(
                    actionGlobalSendInfoFragment(
                        assetInformation = assetInformation,
                        fromAccountAddress = accountCacheData.account.address,
                        isLocked = false
                    )
                )
            }
            FlowType.RESULT -> {
                setNavigationResult(ASSET_SELECTION_KEY, Result(accountCacheData, assetInformation))
                navBack()
            }
        }
    }

    @Parcelize
    data class Result(
        val accountCacheData: AccountCacheData,
        val assetInformation: AssetInformation
    ) : Parcelable

    enum class FlowType {
        REQUEST,
        SEND,
        RESULT
    }

    companion object {
        const val ASSET_SELECTION_KEY = "asset_selection_key"
    }
}
