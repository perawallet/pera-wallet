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
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.databinding.FragmentAssetSelectionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.nft.ui.model.AssetSelectionPreview
import com.algorand.android.nft.ui.model.RequestOptInConfirmationArgs
import com.algorand.android.nft.ui.nfttransferconfirmed.CollectibleTransferConfirmedFragment.Companion.SEND_PURE_COLLECTIBLE_RESULT_KEY
import com.algorand.android.ui.send.assetselection.adapter.SelectSendingAssetAdapter
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.useFragmentResultListenerValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

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

    private val assetSelectionAdapter = SelectSendingAssetAdapter(::onAssetClick)

    private val assetSelectionPreviewCollector: suspend (preview: AssetSelectionPreview) -> Unit = {
        updateUiWithPreview(it)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        showTransactionTipsIfNeed()
        initObservers()
        binding.assetsToSendRecyclerView.adapter = assetSelectionAdapter
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            assetSelectionViewModel.assetSelectionPreview,
            assetSelectionPreviewCollector
        )
    }

    private fun initSavedStateListener() {
        useFragmentResultListenerValue<Boolean>(SEND_PURE_COLLECTIBLE_RESULT_KEY) { isSent ->
            if (isSent) nav(AssetSelectionFragmentDirections.actionSendAlgoNavigationPop())
        }
    }

    private fun updateUiWithPreview(assetSelectionPreview: AssetSelectionPreview) {
        with(assetSelectionPreview) {
            binding.progressBar.loadingProgressBar.isVisible =
                isAssetListLoadingVisible || isReceiverAccountOptInCheckLoadingVisible
            assetList?.let { assetSelectionAdapter.submitList(it) }
            navigateToOptInEvent?.consume()?.run {
                val receiverPublicKey = assetTransaction.receiverUser?.publicKey ?: return@run
                val senderPublicKey = assetTransaction.senderAddress
                navToRequestOptInBottomSheet(this, receiverPublicKey, senderPublicKey)
            }
            navigateToAssetTransferAmountFragmentEvent?.consume()?.run {
                navToAssetTransferAmountFragment(this)
            }
            navigateToCollectibleSendFragmentEvent?.consume()?.let {
                navToCollectibleSendFragment(it.ownerAccountAddress.publicKey, it.collectibleId)
            }
        }
    }

    private fun onAssetClick(assetId: Long) {
        assetSelectionViewModel.updatePreviewWithSelectedAsset(assetId)
    }

    private fun navToAssetTransferAmountFragment(assetId: Long) {
        val assetTransaction = assetSelectionViewModel.assetTransaction.copy(assetId = assetId)
        nav(
            AssetSelectionFragmentDirections.actionAssetSelectionFragmentToAssetTransferAmountFragment(
                assetTransaction
            )
        )
    }

    private fun showTransactionTipsIfNeed() {
        if (assetSelectionViewModel.shouldShowTransactionTips()) {
            nav(AssetSelectionFragmentDirections.actionAssetSelectionFragmentToTransactionTipsBottomSheet())
        }
    }

    private fun navToRequestOptInBottomSheet(
        assetId: Long,
        receiverPublicKey: String,
        senderPublicKey: String
    ) {
        nav(
            AssetSelectionFragmentDirections.actionAssetSelectionFragmentToRequestOptInConfirmationNavigation(
                RequestOptInConfirmationArgs(
                    senderPublicKey = senderPublicKey,
                    receiverPublicKey = receiverPublicKey,
                    assetId = assetId,
                    assetName = assetSelectionViewModel.getAssetOrCollectibleNameOrNull(assetId)
                )
            )
        )
    }

    private fun navToCollectibleSendFragment(senderAddress: String, nftId: Long) {
        nav(
            HomeNavigationDirections.actionGlobalSendCollectibleNavigation(
                accountAddress = senderAddress,
                nftId = nftId
            )
        )
    }
}
