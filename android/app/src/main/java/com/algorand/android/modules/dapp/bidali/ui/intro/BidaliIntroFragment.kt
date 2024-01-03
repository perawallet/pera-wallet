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

package com.algorand.android.modules.dapp.bidali.ui.intro

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentBidaliIntroBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.dapp.bidali.ui.intro.model.BidaliIntroPreview
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class BidaliIntroFragment : BaseFragment(R.layout.fragment_bidali_intro) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.buy_gift_cards_with_bidali,
        startIconResId = R.drawable.ic_close,
        backgroundColor = R.color.bidali,
        titleColor = R.color.white,
        startIconColor = R.color.white,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val bidaliIntroViewModel by viewModels<BidaliIntroViewModel>()
    private val binding by viewBinding(FragmentBidaliIntroBinding::bind)

    private val statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.bidali)

    private val bidaliIntroPreviewCollector: suspend (BidaliIntroPreview) -> Unit = { preview ->
        updateUiWithPreview(preview)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        changeStatusBarConfiguration(statusBarConfiguration)
        binding.buyGiftCardsButton.setOnClickListener { onBuyGiftCardsButtonClick() }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectOnLifecycle(
            bidaliIntroViewModel.bidaliIntroPreviewFlow,
            bidaliIntroPreviewCollector,
        )
    }

    private fun onBuyGiftCardsButtonClick() {
        bidaliIntroViewModel.onBuyGiftCardsButtonClick()
    }

    private fun updateUiWithPreview(preview: BidaliIntroPreview) {
        with(preview) {
            navigateEvent?.consume()?.let {
                nav(it)
            }

            showNotAvailableErrorEvent?.consume()?.let {
                showNotAvailableError()
            }
        }
    }

    private fun showNotAvailableError() {
        showGlobalError(getString(R.string.you_can_not_purchase_bidali), getString(R.string.not_available))
    }
}
