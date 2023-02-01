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

package com.algorand.android.modules.swap.previewsummary.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetSwapPreviewSummaryBinding
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.swap.previewsummary.ui.model.SwapPreviewSummaryPreview
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.AccountIconDrawable
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SwapPreviewSummaryBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_swap_preview_summary) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.swap_summary,
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_close
    )

    private val binding by viewBinding(BottomSheetSwapPreviewSummaryBinding::bind)

    private val swapPreviewSummaryViewModel by viewModels<SwapPreviewSummaryViewModel>()

    private val swapPreviewSummaryPreviewCollector: suspend (SwapPreviewSummaryPreview) -> Unit = { preview ->
        initPreview(preview)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            toolbar.configure(toolbarConfiguration)
            priceRatioTextView.setOnClickListener { onSwitchPriceRatioClick() }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            swapPreviewSummaryViewModel.swapPreviewSummaryPreviewFlow,
            swapPreviewSummaryPreviewCollector
        )
    }

    private fun initPreview(preview: SwapPreviewSummaryPreview) {
        with(preview) {
            initAccountDetails(accountDisplayName, accountIconResource)
            with(binding) {
                priceRatioTextView.text = root.context.getXmlStyledString(getPriceRatio(resources))
                slippageToleranceTextView.text = slippageTolerance
                priceImpactTextView.text = getString(R.string.formatted_percentage, priceImpact)
                minimumReceivedTextView.text = root.context.getXmlStyledString(minimumReceived)
                exchangeFeeTextView.text = formattedExchangeFee
                peraFeeTextView.text = formattedPeraFee
                totalSwapFeeTextView.text = formattedTotalFee
            }
        }
    }

    private fun initAccountDetails(accountDisplayName: AccountDisplayName, accountIconResource: AccountIconResource) {
        with(binding) {
            val iconSize = resources.getDimensionPixelSize(R.dimen.account_icon_size_normal)
            val accountIconDrawable = AccountIconDrawable.create(root.context, accountIconResource, iconSize)
            val accountName = accountDisplayName.getAccountPrimaryDisplayName()
            accountTextView.apply {
                setDrawable(start = accountIconDrawable)
                text = accountName
            }
        }
    }

    private fun onSwitchPriceRatioClick() {
        val newPriceRatio = swapPreviewSummaryViewModel.getUpdatedPriceRatio(resources)
        binding.priceRatioTextView.text = context?.getXmlStyledString(newPriceRatio)
    }
}
