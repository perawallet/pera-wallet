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

package com.algorand.android.modules.assets.profile.about.ui

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.core.os.bundleOf
import androidx.core.view.isVisible
import androidx.core.view.updatePadding
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAssetAboutBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.modules.assets.profile.about.ui.adapter.AssetAboutAdapter
import com.algorand.android.modules.assets.profile.about.ui.model.AssetAboutPreview
import com.algorand.android.utils.browser.openAccountAddressInPeraExplorer
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.composeReportAssetEmail
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest

@AndroidEntryPoint
class AssetAboutFragment : BaseFragment(R.layout.fragment_asset_about) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val assetAboutViewModel by viewModels<AssetAboutViewModel>()

    private val binding by viewBinding(FragmentAssetAboutBinding::bind)

    private var assetAboutTabListener: AssetAboutTabListener? = null

    private val assetAboutPreviewCollector: suspend (value: AssetAboutPreview?) -> Unit = { preview ->
        if (preview != null) updatePreview(preview)
    }

    private val assetAboutListener = object : AssetAboutAdapter.AssetAboutListener {
        override fun onUrlClick(url: String) {
            context?.openUrl(url)
        }

        override fun onReportClick(assetId: Long, assetShortName: String) {
            context?.composeReportAssetEmail(
                assetId = assetId,
                assetShortName = assetShortName,
                onActivityNotFound = { assetAboutTabListener?.onReportActionFailed() }
            )
        }

        override fun onTotalSupplyInfoClick() {
            assetAboutTabListener?.onTotalSupplyClick()
        }

        override fun onCreatorAddressClick(creatorAddress: String) {
            context?.openAccountAddressInPeraExplorer(
                accountAddress = creatorAddress,
                networkSlug = assetAboutViewModel.getActiveNodeNetworkSlug()
            )
        }

        override fun onAccountAddressLongClick(accountAddress: String) {
            onAccountAddressCopied(accountAddress)
        }
    }

    private val assetAboutAdapter = AssetAboutAdapter(listener = assetAboutListener)

    override fun onAttach(context: Context) {
        super.onAttach(context)
        assetAboutTabListener = parentFragment as? AssetAboutTabListener
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        binding.assetAboutRecyclerView.adapter = assetAboutAdapter
        setBottomPaddingIfNeed()
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenResumed {
            assetAboutViewModel.assetAboutPreviewFlow.collectLatest(assetAboutPreviewCollector)
        }
    }

    private fun updatePreview(preview: AssetAboutPreview) {
        assetAboutAdapter.submitList(preview.assetAboutListItems)
        binding.progressBar.root.isVisible = preview.isLoading
    }

    private fun setBottomPaddingIfNeed() {
        if (!assetAboutViewModel.isBottomPaddingNeeded) return
        with(binding.assetAboutRecyclerView) {
            updatePadding(bottom = resources.getDimensionPixelSize(R.dimen.asa_action_layout_height))
            clipToPadding = false
        }
    }

    override fun onDestroyView() {
        assetAboutViewModel.clearAsaProfileLocalCache()
        super.onDestroyView()
    }

    interface AssetAboutTabListener {
        fun onReportActionFailed()
        fun onTotalSupplyClick()
    }

    companion object {
        fun newInstance(assetId: Long, isBottomPaddingNeeded: Boolean): AssetAboutFragment {
            return AssetAboutFragment().apply {
                arguments = bundleOf(
                    AssetAboutViewModel.ASSET_ID_KEY to assetId,
                    AssetAboutViewModel.IS_BOTTOM_PADDING_NEEDED_KEY to isBottomPaddingNeeded
                )
            }
        }
    }
}
