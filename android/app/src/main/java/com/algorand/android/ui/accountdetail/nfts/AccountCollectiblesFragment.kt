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

package com.algorand.android.ui.accountdetail.nfts

import android.content.Context
import android.os.Bundle
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.nft.ui.nftlisting.BaseCollectiblesListingFragment
import com.algorand.android.utils.extensions.hide
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect

@AndroidEntryPoint
class AccountCollectiblesFragment : BaseCollectiblesListingFragment() {

    override val fragmentConfiguration = FragmentConfiguration()

    override val isTitleVisible: Boolean
        get() = false

    private val accountCollectiblesViewModel by viewModels<AccountCollectiblesViewModel>()

    private var listener: Listener? = null

    override fun onVideoItemClick(collectibleAssetId: Long, publicKey: String) {
        listener?.onVideoItemClick(collectibleAssetId)
    }

    override fun onImageItemClick(collectibleAssetId: Long, publicKey: String) {
        listener?.onImageItemClick(collectibleAssetId)
    }

    override fun onSoundItemClick(collectibleAssetId: Long, publicKey: String) {
        listener?.onSoundItemClick(collectibleAssetId)
    }

    override fun onGifItemClick(collectibleAssetId: Long, publicKey: String) {
        listener?.onGifItemClick(collectibleAssetId)
    }

    override fun onNotSupportedItemClick(collectibleAssetId: Long, publicKey: String) {
        listener?.onNotSupportedItemClick(collectibleAssetId)
    }

    override fun onMixedItemClick(collectibleAssetId: Long, publicKey: String) {
        listener?.onMixedItemClick(collectibleAssetId)
    }

    override fun onReceiveCollectibleClick() {
        listener?.onReceiveCollectibleClick()
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = parentFragment as? Listener
    }

    override fun initUi() {
        super.initUi()
        binding.titleTextView.hide()
    }

    override fun initCollectiblesListingPreviewCollector() {
        viewLifecycleOwner.lifecycleScope.launchWhenStarted {
            accountCollectiblesViewModel.collectiblesListingPreviewFlow.collect(collectibleListingPreviewCollector)
        }
    }

    override fun updateUiWithReceiveButtonVisibility(isVisible: Boolean) {
        // Nothing to do
    }

    interface Listener {
        fun onImageItemClick(nftAssetId: Long)
        fun onVideoItemClick(nftAssetId: Long)
        fun onSoundItemClick(nftAssetId: Long)
        fun onGifItemClick(nftAssetId: Long)
        fun onNotSupportedItemClick(nftAssetId: Long)
        fun onMixedItemClick(nftAssetId: Long)
        fun onReceiveCollectibleClick()
    }

    companion object {
        const val PUBLIC_KEY = "public_key"
        fun newInstance(publicKey: String): AccountCollectiblesFragment {
            return AccountCollectiblesFragment().apply {
                arguments = Bundle().apply { putString(PUBLIC_KEY, publicKey) }
            }
        }
    }
}
