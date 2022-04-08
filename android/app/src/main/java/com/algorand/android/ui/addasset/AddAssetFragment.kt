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

package com.algorand.android.ui.addasset

import androidx.core.widget.ContentLoadingProgressBar
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.customviews.AlgorandTabLayout
import com.algorand.android.customviews.ScreenStateView
import com.algorand.android.databinding.FragmentAddAssetBinding
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetQueryType
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.showAlertDialog
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
        get() = args.accountPublicKey

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.add_new_asset,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::onBackPressed,
        showNodeStatus = true
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentAddAssetBinding::bind)

    private val addAssetViewModel: AddAssetViewModel by viewModels()

    override val baseAddAssetViewModel: BaseAddAssetViewModel
        get() = addAssetViewModel

    private val algorandTabLayoutListener = object : AlgorandTabLayout.Listener {
        override fun onLeftTabSelected() {
            addAssetViewModel.queryType = AssetQueryType.VERIFIED
        }

        override fun onRightTabSelected() {
            addAssetViewModel.queryType = AssetQueryType.ALL
        }
    }

    override fun initUi() {
        addAssetViewModel.start(getString(R.string.the_internet_connection))
        setupToolbar()
        with(binding) {
            algorandTabLayout.setListener(algorandTabLayoutListener)
            searchBar.setOnTextChanged { addAssetViewModel.queryText = it }
            screenStateView.setOnNeutralButtonClickListener { addAssetViewModel.refreshTransactionHistory() }
            assetsRecyclerView.adapter = assetSearchAdapter
        }
    }

    private fun setupToolbar() {
        getAppToolbar()?.addButtonToEnd(IconButton(R.drawable.ic_info, onClick = ::onInfoClick))
    }

    override fun onSendTransactionSuccess() {
        nav(AddAssetFragmentDirections.actionAddAssetFragmentToAccountsFragment())
    }

    override fun navigateToAssetAdditionBottomSheet(assetAdditionAssetAction: AssetAction) {
        nav(AddAssetFragmentDirections.actionAddAssetFragmentToAddAssetActionBottomSheet(assetAdditionAssetAction))
    }

    override fun onAssetAlreadyOwned() {
        context?.showAlertDialog(getString(R.string.error), getString(R.string.you_already_have))
    }

    private fun onInfoClick() {
        nav(AddAssetFragmentDirections.actionAddAssetFragmentToVerifiedAssetInformationBottomSheet())
    }
}
