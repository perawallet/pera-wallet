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

package com.algorand.android.modules.assets.addition.ui

import androidx.core.widget.ContentLoadingProgressBar
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.customviews.ScreenStateView
import com.algorand.android.databinding.FragmentAddAssetBinding
import com.algorand.android.models.AssetAction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.assets.addition.base.ui.BaseAddAssetFragment
import com.algorand.android.modules.assets.addition.base.ui.BaseAddAssetViewModel
import com.algorand.android.modules.assets.addition.ui.model.AssetAdditionType
import com.algorand.android.utils.BaseCustomDividerItemDecoration
import com.algorand.android.utils.addCustomDivider
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AddAssetFragment : BaseAddAssetFragment(R.layout.fragment_add_asset) {

    private val args: AddAssetFragmentArgs by navArgs()

    override val loadingProgressBar: ContentLoadingProgressBar
        get() = binding.loadingProgressBar

    override val screenStateView: ScreenStateView
        get() = binding.screenStateView

    override val assetsRecyclerView: RecyclerView
        get() = binding.assetsRecyclerView

    override val fragmentResId: Int
        get() = R.id.addAssetFragment

    override val accountPublicKey: String
        get() = args.accountAddress

    override val assetAdditionType: AssetAdditionType
        get() = AssetAdditionType.ASSET

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.opt_in_to_an,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::onBackPressed
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentAddAssetBinding::bind)

    private val addAssetViewModel: AddAssetViewModel by viewModels()

    override val baseAddAssetViewModel: BaseAddAssetViewModel
        get() = addAssetViewModel

    override fun initUi() {
        setupToolbar()
        with(binding) {
            searchBar.setOnTextChanged { addAssetViewModel.updateQuery(it) }
            screenStateView.setOnNeutralButtonClickListener { addAssetViewModel.refreshTransactionHistory() }
            assetsRecyclerView.adapter = assetSearchAdapter
            assetsRecyclerView.addCustomDivider(
                drawableResId = R.drawable.horizontal_divider_80_24dp,
                showLast = false,
                divider = BaseCustomDividerItemDecoration()
            )
        }
    }

    private fun setupToolbar() {
        getAppToolbar()?.setEndButton(button = IconButton(R.drawable.ic_info, onClick = ::onInfoClick))
    }

    override fun navigateToAssetAdditionBottomSheet(assetAdditionAssetAction: AssetAction) {
        nav(
            AddAssetFragmentDirections.actionAddAssetFragmentToAssetAdditionActionNavigation(
                assetAction = assetAdditionAssetAction
            )
        )
    }

    override fun onNavigateAssetItemDetail(assetId: Long) {
        nav(
            AddAssetFragmentDirections.actionAddAssetFragmentToAsaProfileNavigation(
                assetId = assetId,
                accountAddress = accountPublicKey
            )
        )
    }

    override fun onNavigateCollectibleDetail(collectibleId: Long) {
        nav(
            AddAssetFragmentDirections.actionAddAssetFragmentToCollectibleProfileNavigation(
                accountAddress = accountPublicKey,
                collectibleId = collectibleId
            )
        )
    }

    private fun onInfoClick() {
        nav(AddAssetFragmentDirections.actionAddAssetFragmentToAssetVerificationInfoFragment())
    }
}
