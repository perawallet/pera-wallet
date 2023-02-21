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

package com.algorand.android.nft.cardviewer.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.databinding.FragmentNftCardViewerWebViewBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.modules.basewebview.ui.BaseWebViewFragment
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class NFTCardViewerWebViewFragment : BaseWebViewFragment(R.layout.fragment_nft_card_viewer_web_view) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val binding by viewBinding(FragmentNftCardViewerWebViewBinding::bind)

    private val nftCardViewerWebViewViewModel by viewModels<NFTCardViewerWebViewViewModel>()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
    }

    private fun initUi() {
        with(binding) {
            peraWebView.loadUrl(nftCardViewerWebViewViewModel.nftCardViewUrl)
            closeButton.setOnClickListener { navBack() }
        }
    }
}
