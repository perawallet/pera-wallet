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

package com.algorand.android.ui.send.assetselection

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.databinding.FragmentAssetSelectionBinding
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetSelection
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.send.assetselection.adapter.AssetSelectionAdapter
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AssetSelectionFragment : TransactionBaseFragment(R.layout.fragment_asset_selection) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.select_the_asset_to_send,
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_left_arrow
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentAssetSelectionBinding::bind)

    private val assetSelectionViewModel: AssetSelectionViewModel by viewModels()

    private val assetSelectionAdapter = AssetSelectionAdapter(::onAssetClick)

    private val assetSelectionCollector: suspend (value: List<AssetSelection>?) -> Unit = {
        it?.let { assetSelectionAdapter.submitList(it) }
    }

    override val transactionFragmentListener = object : TransactionFragmentListener {

        override fun onSignTransactionLoading() {
            showProgress()
        }

        override fun onSignTransactionLoadingFinished() {
            hideProgress()
        }

        override fun onSignTransactionFinished(signedTransactionDetail: SignedTransactionDetail) {
            when (signedTransactionDetail) {
                is SignedTransactionDetail.Send -> {
                    nav(
                        AssetSelectionFragmentDirections
                            .actionAssetSelectionFragmentToAssetTransferPreviewFragment(signedTransactionDetail)
                    )
                }
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        showTransactionTipsIfNeed()
        initObservers()
        binding.assetsToSendRecyclerView.adapter = assetSelectionAdapter
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            assetSelectionViewModel.assetSelectionFlow.collectLatest(assetSelectionCollector)
        }
    }

    private fun onAssetClick(assetInformation: AssetInformation) {
        val assetTransaction = assetSelectionViewModel.assetTransaction.copy(
            assetId = assetInformation.assetId
        )
        nav(
            AssetSelectionFragmentDirections.actionAssetSelectionFragmentToAssetTransferAmountFragment(assetTransaction)
        )
    }

    private fun showProgress() {
        binding.progressBar.root.show()
    }

    private fun hideProgress() {
        binding.progressBar.root.hide()
    }

    private fun showTransactionTipsIfNeed() {
        if (assetSelectionViewModel.shouldShowTransactionTips()) {
            nav(AssetSelectionFragmentDirections.actionAssetSelectionFragmentToTransactionTipsBottomSheet())
        }
    }
}
